BREAKPAD_DIR=$${PWD}/breakpad
INCLUDEPATH += $${BREAKPAD_DIR}
INCLUDEPATH += $${BREAKPAD_DIR}/src

QMAKE_CXXFLAGS += -std=c++0x

# Windows
win32 {
    HEADERS += $${BREAKPAD_DIR}/src/common/windows/string_utils-inl.h
    HEADERS += $${BREAKPAD_DIR}/src/common/windows/guid_string.h
    HEADERS += $${BREAKPAD_DIR}/src/client/windows/handler/exception_handler.h
    HEADERS += $${BREAKPAD_DIR}/src/client/windows/common/ipc_protocol.h
    HEADERS += $${BREAKPAD_DIR}/src/google_breakpad/common/minidump_format.h
    HEADERS += $${BREAKPAD_DIR}/src/google_breakpad/common/breakpad_types.h
    HEADERS += $${BREAKPAD_DIR}/src/client/windows/crash_generation/crash_generation_client.h
    HEADERS += $${BREAKPAD_DIR}/src/common/scoped_ptr.h

    SOURCES += $${BREAKPAD_DIR}/src/client/windows/handler/exception_handler.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/windows/string_utils.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/windows/guid_string.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/windows/crash_generation/crash_generation_client.cc
}

# Linux
unix:!macx {
    HEADERS += $${BREAKPAD_DIR}/src/client/linux/minidump_writer/cpu_set.h
    HEADERS += $${BREAKPAD_DIR}/src/client/linux/minidump_writer/proc_cpuinfo_reader.h
    HEADERS += $${BREAKPAD_DIR}/src/client/linux/handler/exception_handler.h
    HEADERS += $${BREAKPAD_DIR}/src/client/linux/crash_generation/crash_generation_client.h
    HEADERS += $${BREAKPAD_DIR}/src/client/linux/handler/minidump_descriptor.h
    HEADERS += $${BREAKPAD_DIR}/src/client/linux/minidump_writer/minidump_writer.h
    HEADERS += $${BREAKPAD_DIR}/src/client/linux/microdump_writer/microdump_writer.h
    HEADERS += $${BREAKPAD_DIR}/src/client/linux/minidump_writer/line_reader.h
    HEADERS += $${BREAKPAD_DIR}/src/client/linux/minidump_writer/linux_dumper.h
    HEADERS += $${BREAKPAD_DIR}/src/client/linux/minidump_writer/linux_ptrace_dumper.h
    HEADERS += $${BREAKPAD_DIR}/src/client/linux/minidump_writer/directory_reader.h
    HEADERS += $${BREAKPAD_DIR}/src/client/linux/dump_writer_common/ucontext_reader.h
    HEADERS += $${BREAKPAD_DIR}/src/client/linux/dump_writer_common/thread_info.h
    HEADERS += $${BREAKPAD_DIR}/src/client/linux/log/log.h
    HEADERS += $${BREAKPAD_DIR}/src/client/minidump_file_writer-inl.h
    HEADERS += $${BREAKPAD_DIR}/src/client/minidump_file_writer.h
    HEADERS += $${BREAKPAD_DIR}/src/common/linux/linux_libc_support.h
    HEADERS += $${BREAKPAD_DIR}/src/common/linux/eintr_wrapper.h
    HEADERS += $${BREAKPAD_DIR}/src/common/linux/ignore_ret.h
    HEADERS += $${BREAKPAD_DIR}/src/common/linux/file_id.h
    HEADERS += $${BREAKPAD_DIR}/src/common/linux/memory_mapped_file.h
    HEADERS += $${BREAKPAD_DIR}/src/common/linux/safe_readlink.h
    HEADERS += $${BREAKPAD_DIR}/src/common/linux/guid_creator.h
    HEADERS += $${BREAKPAD_DIR}/src/common/linux/elfutils.h
    HEADERS += $${BREAKPAD_DIR}/src/common/linux/elfutils-inl.h
    HEADERS += $${BREAKPAD_DIR}/src/common/linux/elf_gnu_compat.h
    HEADERS += $${BREAKPAD_DIR}/src/common/using_std_string.h
    HEADERS += $${BREAKPAD_DIR}/src/common/basictypes.h
    HEADERS += $${BREAKPAD_DIR}/src/common/memory_range.h
    HEADERS += $${BREAKPAD_DIR}/src/common/string_conversion.h
    HEADERS += $${BREAKPAD_DIR}/src/common/convert_UTF.h
    HEADERS += $${BREAKPAD_DIR}/src/google_breakpad/common/minidump_format.h
    HEADERS += $${BREAKPAD_DIR}/src/google_breakpad/common/minidump_size.h
    HEADERS += $${BREAKPAD_DIR}/src/google_breakpad/common/breakpad_types.h
    HEADERS += $${BREAKPAD_DIR}/src/common/scoped_ptr.h
    HEADERS += $${BREAKPAD_DIR}/src/third_party/lss/linux_syscall_support.h

    SOURCES += $${BREAKPAD_DIR}/src/client/linux/crash_generation/crash_generation_client.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/linux/handler/exception_handler.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/linux/handler/minidump_descriptor.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/linux/microdump_writer/microdump_writer.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/linux/minidump_writer/minidump_writer.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/linux/minidump_writer/linux_dumper.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/linux/minidump_writer/linux_ptrace_dumper.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/linux/dump_writer_common/ucontext_reader.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/linux/dump_writer_common/thread_info.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/linux/log/log.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/minidump_file_writer.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/linux/linux_libc_support.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/linux/file_id.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/linux/memory_mapped_file.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/linux/safe_readlink.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/linux/guid_creator.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/linux/elfutils.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/string_conversion.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/convert_UTF.c
}

# MacOSX
macx {
    HEADERS += $${BREAKPAD_DIR}/src/client/minidump_file_writer.h
    HEADERS += $${BREAKPAD_DIR}/src/common/convert_UTF.h
    HEADERS += $${BREAKPAD_DIR}/src/common/string_conversion.h
    HEADERS += $${BREAKPAD_DIR}/src/client/mac/crash_generation/crash_generation_client.h
    HEADERS += $${BREAKPAD_DIR}/src/client/mac/crash_generation/crash_generation_server.h
    HEADERS += $${BREAKPAD_DIR}/src/client/mac/crash_generation/crash_generation_server.cc
    HEADERS += $${BREAKPAD_DIR}/src/client/mac/handler/breakpad_nlist_64.h
    HEADERS += $${BREAKPAD_DIR}/src/client/mac/handler/dynamic_images.h
    HEADERS += $${BREAKPAD_DIR}/src/client/mac/handler/exception_handler.h
    HEADERS += $${BREAKPAD_DIR}/src/client/mac/handler/minidump_generator.h
    HEADERS += $${BREAKPAD_DIR}/src/client/mac/handler/protected_memory_allocator.h
    HEADERS += $${BREAKPAD_DIR}/src/common/mac/file_id.h
    HEADERS += $${BREAKPAD_DIR}/src/common/mac/macho_id.h
    HEADERS += $${BREAKPAD_DIR}/src/common/mac/macho_reader.h
    HEADERS += $${BREAKPAD_DIR}/src/common/mac/macho_utilities.h
    HEADERS += $${BREAKPAD_DIR}/src/common/mac/macho_walker.h
    HEADERS += $${BREAKPAD_DIR}/src/common/mac/string_utilities.h
    HEADERS += $${BREAKPAD_DIR}/src/common/md5.h

    SOURCES += $${BREAKPAD_DIR}/src/client/minidump_file_writer.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/convert_UTF.c
    SOURCES += $${BREAKPAD_DIR}/src/common/string_conversion.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/mac/crash_generation/crash_generation_client.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/mac/crash_generation/crash_generation_server.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/mac/handler/breakpad_nlist_64.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/mac/handler/dynamic_images.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/mac/handler/exception_handler.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/mac/handler/minidump_generator.cc
    SOURCES += $${BREAKPAD_DIR}/src/client/mac/handler/protected_memory_allocator.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/mac/file_id.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/mac/macho_id.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/mac/macho_reader.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/mac/macho_utilities.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/mac/macho_walker.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/mac/string_utilities.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/md5.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/mac/dump_syms.mm
    SOURCES += $${BREAKPAD_DIR}/src/common/mac/MachIPC.mm
    SOURCES += $${BREAKPAD_DIR}/src/common/dwarf/dwarf2reader.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/mac/bootstrap_compat.cc
    SOURCES += $${BREAKPAD_DIR}/src/common/dwarf_cfi_to_module.cc
}
