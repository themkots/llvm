//===-- CommandCompletions.cpp --------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/StringSet.h"

#include "lldb/Breakpoint/Watchpoint.h"
#include "lldb/Core/FileSpecList.h"
#include "lldb/Core/Module.h"
#include "lldb/Core/PluginManager.h"
#include "lldb/DataFormatters/DataVisualization.h"
#include "lldb/Host/FileSystem.h"
#include "lldb/Interpreter/CommandCompletions.h"
#include "lldb/Interpreter/CommandInterpreter.h"
#include "lldb/Interpreter/OptionValueProperties.h"
#include "lldb/Symbol/CompileUnit.h"
#include "lldb/Symbol/Variable.h"
#include "lldb/Target/Language.h"
#include "lldb/Target/Process.h"
#include "lldb/Target/RegisterContext.h"
#include "lldb/Target/Thread.h"
#include "lldb/Utility/FileSpec.h"
#include "lldb/Utility/StreamString.h"
#include "lldb/Utility/TildeExpressionResolver.h"

#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Path.h"

using namespace lldb_private;

// This is the command completion callback that is used to complete the
// argument of the option it is bound to (in the OptionDefinition table
// below).
typedef void (*CompletionCallback)(CommandInterpreter &interpreter,
                                   CompletionRequest &request,
                                   // A search filter to limit the search...
                                   lldb_private::SearchFilter *searcher);

struct CommonCompletionElement {
  uint32_t type;
  CompletionCallback callback;
};

bool CommandCompletions::InvokeCommonCompletionCallbacks(
    CommandInterpreter &interpreter, uint32_t completion_mask,
    CompletionRequest &request, SearchFilter *searcher) {
  bool handled = false;

  const CommonCompletionElement common_completions[] = {
      {eSourceFileCompletion, CommandCompletions::SourceFiles},
      {eDiskFileCompletion, CommandCompletions::DiskFiles},
      {eDiskDirectoryCompletion, CommandCompletions::DiskDirectories},
      {eSymbolCompletion, CommandCompletions::Symbols},
      {eModuleCompletion, CommandCompletions::Modules},
      {eModuleUUIDCompletion, CommandCompletions::ModuleUUIDs},
      {eSettingsNameCompletion, CommandCompletions::SettingsNames},
      {ePlatformPluginCompletion, CommandCompletions::PlatformPluginNames},
      {eArchitectureCompletion, CommandCompletions::ArchitectureNames},
      {eVariablePathCompletion, CommandCompletions::VariablePath},
      {eRegisterCompletion, CommandCompletions::Registers},
      {eBreakpointCompletion, CommandCompletions::Breakpoints},
      {eProcessPluginCompletion, CommandCompletions::ProcessPluginNames},
      {eDisassemblyFlavorCompletion, CommandCompletions::DisassemblyFlavors},
      {eTypeLanguageCompletion, CommandCompletions::TypeLanguages},
      {eFrameIndexCompletion, CommandCompletions::FrameIndexes},
      {eStopHookIDCompletion, CommandCompletions::StopHookIDs},
      {eThreadIndexCompletion, CommandCompletions::ThreadIndexes},
      {eWatchPointIDCompletion, CommandCompletions::WatchPointIDs},
      {eBreakpointNameCompletion, CommandCompletions::BreakpointNames},
      {eProcessIDCompletion, CommandCompletions::ProcessIDs},
      {eProcessNameCompletion, CommandCompletions::ProcessNames},
      {eRemoteDiskFileCompletion, CommandCompletions::RemoteDiskFiles},
      {eRemoteDiskDirectoryCompletion,
       CommandCompletions::RemoteDiskDirectories},
      {eTypeCategoryNameCompletion, CommandCompletions::TypeCategoryNames},
      {eNoCompletion, nullptr} // This one has to be last in the list.
  };

  for (int i = 0;; i++) {
    if (common_completions[i].type == eNoCompletion)
      break;
    else if ((common_completions[i].type & completion_mask) ==
                 common_completions[i].type &&
             common_completions[i].callback != nullptr) {
      handled = true;
      common_completions[i].callback(interpreter, request, searcher);
    }
  }
  return handled;
}

namespace {
// The Completer class is a convenient base class for building searchers that
// go along with the SearchFilter passed to the standard Completer functions.
class Completer : public Searcher {
public:
  Completer(CommandInterpreter &interpreter, CompletionRequest &request)
      : m_interpreter(interpreter), m_request(request) {}

  ~Completer() override = default;

  CallbackReturn SearchCallback(SearchFilter &filter, SymbolContext &context,
                                Address *addr) override = 0;

  lldb::SearchDepth GetDepth() override = 0;

  virtual void DoCompletion(SearchFilter *filter) = 0;

protected:
  CommandInterpreter &m_interpreter;
  CompletionRequest &m_request;

private:
  Completer(const Completer &) = delete;
  const Completer &operator=(const Completer &) = delete;
};
} // namespace

// SourceFileCompleter implements the source file completer
namespace {
class SourceFileCompleter : public Completer {
public:
  SourceFileCompleter(CommandInterpreter &interpreter,
                      CompletionRequest &request)
      : Completer(interpreter, request), m_matching_files() {
    FileSpec partial_spec(m_request.GetCursorArgumentPrefix());
    m_file_name = partial_spec.GetFilename().GetCString();
    m_dir_name = partial_spec.GetDirectory().GetCString();
  }

  lldb::SearchDepth GetDepth() override { return lldb::eSearchDepthCompUnit; }

  Searcher::CallbackReturn SearchCallback(SearchFilter &filter,
                                          SymbolContext &context,
                                          Address *addr) override {
    if (context.comp_unit != nullptr) {
      const char *cur_file_name =
          context.comp_unit->GetPrimaryFile().GetFilename().GetCString();
      const char *cur_dir_name =
          context.comp_unit->GetPrimaryFile().GetDirectory().GetCString();

      bool match = false;
      if (m_file_name && cur_file_name &&
          strstr(cur_file_name, m_file_name) == cur_file_name)
        match = true;

      if (match && m_dir_name && cur_dir_name &&
          strstr(cur_dir_name, m_dir_name) != cur_dir_name)
        match = false;

      if (match) {
        m_matching_files.AppendIfUnique(context.comp_unit->GetPrimaryFile());
      }
    }
    return Searcher::eCallbackReturnContinue;
  }

  void DoCompletion(SearchFilter *filter) override {
    filter->Search(*this);
    // Now convert the filelist to completions:
    for (size_t i = 0; i < m_matching_files.GetSize(); i++) {
      m_request.AddCompletion(
          m_matching_files.GetFileSpecAtIndex(i).GetFilename().GetCString());
    }
  }

private:
  FileSpecList m_matching_files;
  const char *m_file_name;
  const char *m_dir_name;

  SourceFileCompleter(const SourceFileCompleter &) = delete;
  const SourceFileCompleter &operator=(const SourceFileCompleter &) = delete;
};
} // namespace

static bool regex_chars(const char comp) {
  return llvm::StringRef("[](){}+.*|^$\\?").contains(comp);
}

namespace {
class SymbolCompleter : public Completer {

public:
  SymbolCompleter(CommandInterpreter &interpreter, CompletionRequest &request)
      : Completer(interpreter, request) {
    std::string regex_str;
    if (!m_request.GetCursorArgumentPrefix().empty()) {
      regex_str.append("^");
      regex_str.append(std::string(m_request.GetCursorArgumentPrefix()));
    } else {
      // Match anything since the completion string is empty
      regex_str.append(".");
    }
    std::string::iterator pos =
        find_if(regex_str.begin() + 1, regex_str.end(), regex_chars);
    while (pos < regex_str.end()) {
      pos = regex_str.insert(pos, '\\');
      pos = find_if(pos + 2, regex_str.end(), regex_chars);
    }
    m_regex = RegularExpression(regex_str);
  }

  lldb::SearchDepth GetDepth() override { return lldb::eSearchDepthModule; }

  Searcher::CallbackReturn SearchCallback(SearchFilter &filter,
                                          SymbolContext &context,
                                          Address *addr) override {
    if (context.module_sp) {
      SymbolContextList sc_list;
      const bool include_symbols = true;
      const bool include_inlines = true;
      context.module_sp->FindFunctions(m_regex, include_symbols,
                                       include_inlines, sc_list);

      SymbolContext sc;
      // Now add the functions & symbols to the list - only add if unique:
      for (uint32_t i = 0; i < sc_list.GetSize(); i++) {
        if (sc_list.GetContextAtIndex(i, sc)) {
          ConstString func_name = sc.GetFunctionName(Mangled::ePreferDemangled);
          // Ensure that the function name matches the regex. This is more than
          // a sanity check. It is possible that the demangled function name
          // does not start with the prefix, for example when it's in an
          // anonymous namespace.
          if (!func_name.IsEmpty() && m_regex.Execute(func_name.GetStringRef()))
            m_match_set.insert(func_name);
        }
      }
    }
    return Searcher::eCallbackReturnContinue;
  }

  void DoCompletion(SearchFilter *filter) override {
    filter->Search(*this);
    collection::iterator pos = m_match_set.begin(), end = m_match_set.end();
    for (pos = m_match_set.begin(); pos != end; pos++)
      m_request.AddCompletion((*pos).GetCString());
  }

private:
  RegularExpression m_regex;
  typedef std::set<ConstString> collection;
  collection m_match_set;

  SymbolCompleter(const SymbolCompleter &) = delete;
  const SymbolCompleter &operator=(const SymbolCompleter &) = delete;
};
} // namespace

namespace {
class ModuleCompleter : public Completer {
public:
  ModuleCompleter(CommandInterpreter &interpreter, CompletionRequest &request)
      : Completer(interpreter, request) {
    FileSpec partial_spec(m_request.GetCursorArgumentPrefix());
    m_file_name = partial_spec.GetFilename().GetCString();
    m_dir_name = partial_spec.GetDirectory().GetCString();
  }

  lldb::SearchDepth GetDepth() override { return lldb::eSearchDepthModule; }

  Searcher::CallbackReturn SearchCallback(SearchFilter &filter,
                                          SymbolContext &context,
                                          Address *addr) override {
    if (context.module_sp) {
      const char *cur_file_name =
          context.module_sp->GetFileSpec().GetFilename().GetCString();
      const char *cur_dir_name =
          context.module_sp->GetFileSpec().GetDirectory().GetCString();

      bool match = false;
      if (m_file_name && cur_file_name &&
          strstr(cur_file_name, m_file_name) == cur_file_name)
        match = true;

      if (match && m_dir_name && cur_dir_name &&
          strstr(cur_dir_name, m_dir_name) != cur_dir_name)
        match = false;

      if (match) {
        m_request.AddCompletion(cur_file_name);
      }
    }
    return Searcher::eCallbackReturnContinue;
  }

  void DoCompletion(SearchFilter *filter) override { filter->Search(*this); }

private:
  const char *m_file_name;
  const char *m_dir_name;

  ModuleCompleter(const ModuleCompleter &) = delete;
  const ModuleCompleter &operator=(const ModuleCompleter &) = delete;
};
} // namespace

void CommandCompletions::SourceFiles(CommandInterpreter &interpreter,
                                     CompletionRequest &request,
                                     SearchFilter *searcher) {
  SourceFileCompleter completer(interpreter, request);

  if (searcher == nullptr) {
    lldb::TargetSP target_sp = interpreter.GetDebugger().GetSelectedTarget();
    SearchFilterForUnconstrainedSearches null_searcher(target_sp);
    completer.DoCompletion(&null_searcher);
  } else {
    completer.DoCompletion(searcher);
  }
}

static void DiskFilesOrDirectories(const llvm::Twine &partial_name,
                                   bool only_directories,
                                   CompletionRequest &request,
                                   TildeExpressionResolver &Resolver) {
  llvm::SmallString<256> CompletionBuffer;
  llvm::SmallString<256> Storage;
  partial_name.toVector(CompletionBuffer);

  if (CompletionBuffer.size() >= PATH_MAX)
    return;

  namespace path = llvm::sys::path;

  llvm::StringRef SearchDir;
  llvm::StringRef PartialItem;

  if (CompletionBuffer.startswith("~")) {
    llvm::StringRef Buffer(CompletionBuffer);
    size_t FirstSep =
        Buffer.find_if([](char c) { return path::is_separator(c); });

    llvm::StringRef Username = Buffer.take_front(FirstSep);
    llvm::StringRef Remainder;
    if (FirstSep != llvm::StringRef::npos)
      Remainder = Buffer.drop_front(FirstSep + 1);

    llvm::SmallString<256> Resolved;
    if (!Resolver.ResolveExact(Username, Resolved)) {
      // We couldn't resolve it as a full username.  If there were no slashes
      // then this might be a partial username.   We try to resolve it as such
      // but after that, we're done regardless of any matches.
      if (FirstSep == llvm::StringRef::npos) {
        llvm::StringSet<> MatchSet;
        Resolver.ResolvePartial(Username, MatchSet);
        for (const auto &S : MatchSet) {
          Resolved = S.getKey();
          path::append(Resolved, path::get_separator());
          request.AddCompletion(Resolved, "", CompletionMode::Partial);
        }
      }
      return;
    }

    // If there was no trailing slash, then we're done as soon as we resolve
    // the expression to the correct directory.  Otherwise we need to continue
    // looking for matches within that directory.
    if (FirstSep == llvm::StringRef::npos) {
      // Make sure it ends with a separator.
      path::append(CompletionBuffer, path::get_separator());
      request.AddCompletion(CompletionBuffer, "", CompletionMode::Partial);
      return;
    }

    // We want to keep the form the user typed, so we special case this to
    // search in the fully resolved directory, but CompletionBuffer keeps the
    // unmodified form that the user typed.
    Storage = Resolved;
    llvm::StringRef RemainderDir = path::parent_path(Remainder);
    if (!RemainderDir.empty()) {
      // Append the remaining path to the resolved directory.
      Storage.append(path::get_separator());
      Storage.append(RemainderDir);
    }
    SearchDir = Storage;
  } else {
    SearchDir = path::parent_path(CompletionBuffer);
  }

  size_t FullPrefixLen = CompletionBuffer.size();

  PartialItem = path::filename(CompletionBuffer);

  // path::filename() will return "." when the passed path ends with a
  // directory separator. We have to filter those out, but only when the
  // "." doesn't come from the completion request itself.
  if (PartialItem == "." && path::is_separator(CompletionBuffer.back()))
    PartialItem = llvm::StringRef();

  if (SearchDir.empty()) {
    llvm::sys::fs::current_path(Storage);
    SearchDir = Storage;
  }
  assert(!PartialItem.contains(path::get_separator()));

  // SearchDir now contains the directory to search in, and Prefix contains the
  // text we want to match against items in that directory.

  FileSystem &fs = FileSystem::Instance();
  std::error_code EC;
  llvm::vfs::directory_iterator Iter = fs.DirBegin(SearchDir, EC);
  llvm::vfs::directory_iterator End;
  for (; Iter != End && !EC; Iter.increment(EC)) {
    auto &Entry = *Iter;
    llvm::ErrorOr<llvm::vfs::Status> Status = fs.GetStatus(Entry.path());

    if (!Status)
      continue;

    auto Name = path::filename(Entry.path());

    // Omit ".", ".."
    if (Name == "." || Name == ".." || !Name.startswith(PartialItem))
      continue;

    bool is_dir = Status->isDirectory();

    // If it's a symlink, then we treat it as a directory as long as the target
    // is a directory.
    if (Status->isSymlink()) {
      FileSpec symlink_filespec(Entry.path());
      FileSpec resolved_filespec;
      auto error = fs.ResolveSymbolicLink(symlink_filespec, resolved_filespec);
      if (error.Success())
        is_dir = fs.IsDirectory(symlink_filespec);
    }

    if (only_directories && !is_dir)
      continue;

    // Shrink it back down so that it just has the original prefix the user
    // typed and remove the part of the name which is common to the located
    // item and what the user typed.
    CompletionBuffer.resize(FullPrefixLen);
    Name = Name.drop_front(PartialItem.size());
    CompletionBuffer.append(Name);

    if (is_dir) {
      path::append(CompletionBuffer, path::get_separator());
    }

    CompletionMode mode =
        is_dir ? CompletionMode::Partial : CompletionMode::Normal;
    request.AddCompletion(CompletionBuffer, "", mode);
  }
}

static void DiskFilesOrDirectories(const llvm::Twine &partial_name,
                                   bool only_directories, StringList &matches,
                                   TildeExpressionResolver &Resolver) {
  CompletionResult result;
  std::string partial_name_str = partial_name.str();
  CompletionRequest request(partial_name_str, partial_name_str.size(), result);
  DiskFilesOrDirectories(partial_name, only_directories, request, Resolver);
  result.GetMatches(matches);
}

static void DiskFilesOrDirectories(CompletionRequest &request,
                                   bool only_directories) {
  StandardTildeExpressionResolver resolver;
  DiskFilesOrDirectories(request.GetCursorArgumentPrefix(), only_directories,
                         request, resolver);
}

void CommandCompletions::DiskFiles(CommandInterpreter &interpreter,
                                   CompletionRequest &request,
                                   SearchFilter *searcher) {
  DiskFilesOrDirectories(request, /*only_dirs*/ false);
}

void CommandCompletions::DiskFiles(const llvm::Twine &partial_file_name,
                                   StringList &matches,
                                   TildeExpressionResolver &Resolver) {
  DiskFilesOrDirectories(partial_file_name, false, matches, Resolver);
}

void CommandCompletions::DiskDirectories(CommandInterpreter &interpreter,
                                         CompletionRequest &request,
                                         SearchFilter *searcher) {
  DiskFilesOrDirectories(request, /*only_dirs*/ true);
}

void CommandCompletions::DiskDirectories(const llvm::Twine &partial_file_name,
                                         StringList &matches,
                                         TildeExpressionResolver &Resolver) {
  DiskFilesOrDirectories(partial_file_name, true, matches, Resolver);
}

void CommandCompletions::RemoteDiskFiles(CommandInterpreter &interpreter,
                                         CompletionRequest &request,
                                         SearchFilter *searcher) {
  lldb::PlatformSP platform_sp =
      interpreter.GetDebugger().GetPlatformList().GetSelectedPlatform();
  if (platform_sp)
    platform_sp->AutoCompleteDiskFileOrDirectory(request, false);
}

void CommandCompletions::RemoteDiskDirectories(CommandInterpreter &interpreter,
                                               CompletionRequest &request,
                                               SearchFilter *searcher) {
  lldb::PlatformSP platform_sp =
      interpreter.GetDebugger().GetPlatformList().GetSelectedPlatform();
  if (platform_sp)
    platform_sp->AutoCompleteDiskFileOrDirectory(request, true);
}

void CommandCompletions::Modules(CommandInterpreter &interpreter,
                                 CompletionRequest &request,
                                 SearchFilter *searcher) {
  ModuleCompleter completer(interpreter, request);

  if (searcher == nullptr) {
    lldb::TargetSP target_sp = interpreter.GetDebugger().GetSelectedTarget();
    SearchFilterForUnconstrainedSearches null_searcher(target_sp);
    completer.DoCompletion(&null_searcher);
  } else {
    completer.DoCompletion(searcher);
  }
}

void CommandCompletions::ModuleUUIDs(CommandInterpreter &interpreter,
                                     CompletionRequest &request,
                                     SearchFilter *searcher) {
  const ExecutionContext &exe_ctx = interpreter.GetExecutionContext();
  if (!exe_ctx.HasTargetScope())
    return;

  exe_ctx.GetTargetPtr()->GetImages().ForEach(
      [&request](const lldb::ModuleSP &module) {
        StreamString strm;
        module->GetDescription(strm.AsRawOstream(),
                               lldb::eDescriptionLevelInitial);
        request.TryCompleteCurrentArg(module->GetUUID().GetAsString(),
                                      strm.GetString());
        return true;
      });
}

void CommandCompletions::Symbols(CommandInterpreter &interpreter,
                                 CompletionRequest &request,
                                 SearchFilter *searcher) {
  SymbolCompleter completer(interpreter, request);

  if (searcher == nullptr) {
    lldb::TargetSP target_sp = interpreter.GetDebugger().GetSelectedTarget();
    SearchFilterForUnconstrainedSearches null_searcher(target_sp);
    completer.DoCompletion(&null_searcher);
  } else {
    completer.DoCompletion(searcher);
  }
}

void CommandCompletions::SettingsNames(CommandInterpreter &interpreter,
                                       CompletionRequest &request,
                                       SearchFilter *searcher) {
  // Cache the full setting name list
  static StringList g_property_names;
  if (g_property_names.GetSize() == 0) {
    // Generate the full setting name list on demand
    lldb::OptionValuePropertiesSP properties_sp(
        interpreter.GetDebugger().GetValueProperties());
    if (properties_sp) {
      StreamString strm;
      properties_sp->DumpValue(nullptr, strm, OptionValue::eDumpOptionName);
      const std::string &str = std::string(strm.GetString());
      g_property_names.SplitIntoLines(str.c_str(), str.size());
    }
  }

  for (const std::string &s : g_property_names)
    request.TryCompleteCurrentArg(s);
}

void CommandCompletions::PlatformPluginNames(CommandInterpreter &interpreter,
                                             CompletionRequest &request,
                                             SearchFilter *searcher) {
  PluginManager::AutoCompletePlatformName(request.GetCursorArgumentPrefix(),
                                          request);
}

void CommandCompletions::ArchitectureNames(CommandInterpreter &interpreter,
                                           CompletionRequest &request,
                                           SearchFilter *searcher) {
  ArchSpec::AutoComplete(request);
}

void CommandCompletions::VariablePath(CommandInterpreter &interpreter,
                                      CompletionRequest &request,
                                      SearchFilter *searcher) {
  Variable::AutoComplete(interpreter.GetExecutionContext(), request);
}

void CommandCompletions::Registers(CommandInterpreter &interpreter,
                                   CompletionRequest &request,
                                   SearchFilter *searcher) {
  std::string reg_prefix = "";
  if (request.GetCursorArgumentPrefix().startswith("$"))
    reg_prefix = "$";

  RegisterContext *reg_ctx =
      interpreter.GetExecutionContext().GetRegisterContext();
  const size_t reg_num = reg_ctx->GetRegisterCount();
  for (size_t reg_idx = 0; reg_idx < reg_num; ++reg_idx) {
    const RegisterInfo *reg_info = reg_ctx->GetRegisterInfoAtIndex(reg_idx);
    request.TryCompleteCurrentArg(reg_prefix + reg_info->name,
                                  reg_info->alt_name);
  }
}

void CommandCompletions::Breakpoints(CommandInterpreter &interpreter,
                                     CompletionRequest &request,
                                     SearchFilter *searcher) {
  lldb::TargetSP target = interpreter.GetDebugger().GetSelectedTarget();
  if (!target)
    return;

  const BreakpointList &breakpoints = target->GetBreakpointList();

  std::unique_lock<std::recursive_mutex> lock;
  target->GetBreakpointList().GetListMutex(lock);

  size_t num_breakpoints = breakpoints.GetSize();
  if (num_breakpoints == 0)
    return;

  for (size_t i = 0; i < num_breakpoints; ++i) {
    lldb::BreakpointSP bp = breakpoints.GetBreakpointAtIndex(i);

    StreamString s;
    bp->GetDescription(&s, lldb::eDescriptionLevelBrief);
    llvm::StringRef bp_info = s.GetString();

    const size_t colon_pos = bp_info.find_first_of(':');
    if (colon_pos != llvm::StringRef::npos)
      bp_info = bp_info.drop_front(colon_pos + 2);

    request.TryCompleteCurrentArg(std::to_string(bp->GetID()), bp_info);
  }
}

void CommandCompletions::BreakpointNames(CommandInterpreter &interpreter,
                                         CompletionRequest &request,
                                         SearchFilter *searcher) {
  lldb::TargetSP target = interpreter.GetDebugger().GetSelectedTarget();
  if (!target)
    return;

  std::vector<std::string> name_list;
  target->GetBreakpointNames(name_list);

  for (const std::string &name : name_list)
    request.TryCompleteCurrentArg(name);
}

void CommandCompletions::ProcessPluginNames(CommandInterpreter &interpreter,
                                            CompletionRequest &request,
                                            SearchFilter *searcher) {
  PluginManager::AutoCompleteProcessName(request.GetCursorArgumentPrefix(),
                                         request);
}
void CommandCompletions::DisassemblyFlavors(CommandInterpreter &interpreter,
                                            CompletionRequest &request,
                                            SearchFilter *searcher) {
  // Currently the only valid options for disassemble -F are default, and for
  // Intel architectures, att and intel.
  static const char *flavors[] = {"default", "att", "intel"};
  for (const char *flavor : flavors) {
    request.TryCompleteCurrentArg(flavor);
  }
}

void CommandCompletions::ProcessIDs(CommandInterpreter &interpreter,
                                    CompletionRequest &request,
                                    SearchFilter *searcher) {
  lldb::PlatformSP platform_sp(interpreter.GetPlatform(true));
  if (!platform_sp)
    return;
  ProcessInstanceInfoList process_infos;
  ProcessInstanceInfoMatch match_info;
  platform_sp->FindProcesses(match_info, process_infos);
  for (const ProcessInstanceInfo &info : process_infos)
    request.TryCompleteCurrentArg(std::to_string(info.GetProcessID()),
                                  info.GetNameAsStringRef());
}

void CommandCompletions::ProcessNames(CommandInterpreter &interpreter,
                                      CompletionRequest &request,
                                      SearchFilter *searcher) {
  lldb::PlatformSP platform_sp(interpreter.GetPlatform(true));
  if (!platform_sp)
    return;
  ProcessInstanceInfoList process_infos;
  ProcessInstanceInfoMatch match_info;
  platform_sp->FindProcesses(match_info, process_infos);
  for (const ProcessInstanceInfo &info : process_infos)
    request.TryCompleteCurrentArg(info.GetNameAsStringRef());
}

void CommandCompletions::TypeLanguages(CommandInterpreter &interpreter,
                                       CompletionRequest &request,
                                       SearchFilter *searcher) {
  for (int bit :
       Language::GetLanguagesSupportingTypeSystems().bitvector.set_bits()) {
    request.TryCompleteCurrentArg(
        Language::GetNameForLanguageType(static_cast<lldb::LanguageType>(bit)));
  }
}

void CommandCompletions::FrameIndexes(CommandInterpreter &interpreter,
                                      CompletionRequest &request,
                                      SearchFilter *searcher) {
  const ExecutionContext &exe_ctx = interpreter.GetExecutionContext();
  if (!exe_ctx.HasProcessScope())
    return;

  lldb::ThreadSP thread_sp = exe_ctx.GetThreadSP();
  const uint32_t frame_num = thread_sp->GetStackFrameCount();
  for (uint32_t i = 0; i < frame_num; ++i) {
    lldb::StackFrameSP frame_sp = thread_sp->GetStackFrameAtIndex(i);
    StreamString strm;
    frame_sp->Dump(&strm, false, true);
    request.TryCompleteCurrentArg(std::to_string(i), strm.GetString());
  }
}

void CommandCompletions::StopHookIDs(CommandInterpreter &interpreter,
                                     CompletionRequest &request,
                                     SearchFilter *searcher) {
  const lldb::TargetSP target_sp =
      interpreter.GetExecutionContext().GetTargetSP();
  if (!target_sp)
    return;

  const size_t num = target_sp->GetNumStopHooks();
  for (size_t idx = 0; idx < num; ++idx) {
    StreamString strm;
    // The value 11 is an offset to make the completion description looks
    // neater.
    strm.SetIndentLevel(11);
    const Target::StopHookSP stophook_sp = target_sp->GetStopHookAtIndex(idx);
    stophook_sp->GetDescription(&strm, lldb::eDescriptionLevelInitial);
    request.TryCompleteCurrentArg(std::to_string(stophook_sp->GetID()),
                                  strm.GetString());
  }
}

void CommandCompletions::ThreadIndexes(CommandInterpreter &interpreter,
                                       CompletionRequest &request,
                                       SearchFilter *searcher) {
  const ExecutionContext &exe_ctx = interpreter.GetExecutionContext();
  if (!exe_ctx.HasProcessScope())
    return;

  ThreadList &threads = exe_ctx.GetProcessPtr()->GetThreadList();
  lldb::ThreadSP thread_sp;
  for (uint32_t idx = 0; (thread_sp = threads.GetThreadAtIndex(idx)); ++idx) {
    StreamString strm;
    thread_sp->GetStatus(strm, 0, 1, 1, true);
    request.TryCompleteCurrentArg(std::to_string(thread_sp->GetIndexID()),
                                  strm.GetString());
  }
}

void CommandCompletions::WatchPointIDs(CommandInterpreter &interpreter,
                                       CompletionRequest &request,
                                       SearchFilter *searcher) {
  const ExecutionContext &exe_ctx = interpreter.GetExecutionContext();
  if (!exe_ctx.HasTargetScope())
    return;

  const WatchpointList &wp_list = exe_ctx.GetTargetPtr()->GetWatchpointList();
  const size_t wp_num = wp_list.GetSize();
  for (size_t idx = 0; idx < wp_num; ++idx) {
    const lldb::WatchpointSP wp_sp = wp_list.GetByIndex(idx);
    StreamString strm;
    wp_sp->Dump(&strm);
    request.TryCompleteCurrentArg(std::to_string(wp_sp->GetID()),
                                  strm.GetString());
  }
}

void CommandCompletions::TypeCategoryNames(CommandInterpreter &interpreter,
                                           CompletionRequest &request,
                                           SearchFilter *searcher) {
  DataVisualization::Categories::ForEach(
      [&request](const lldb::TypeCategoryImplSP &category_sp) {
        request.TryCompleteCurrentArg(category_sp->GetName(),
                                      category_sp->GetDescription());
        return true;
      });
}
