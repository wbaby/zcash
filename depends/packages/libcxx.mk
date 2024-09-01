package=libcxx
$(package)_version=$(if $(native_clang_version_$(host_arch)_$(host_os)),$(native_clang_version_$(host_arch)_$(host_os)),$(if $(native_clang_version_$(host_os)),$(native_clang_version_$(host_os)),$(native_clang_default_version)))
$(package)_msys2_version=18.1.4-1

ifneq ($(canonical_host),$(build))
ifneq ($(host_os),mingw32)
# Clang is provided pre-compiled for a bunch of targets; fetch the one we need
# and stage its copies of the static libraries.
$(package)_download_path=$(native_clang_download_path)
$(package)_download_file_aarch64_linux=clang+llvm-$($(package)_version)-aarch64-linux-gnu.tar.xz
$(package)_file_name_aarch64_linux=clang-llvm-$($(package)_version)-aarch64-linux-gnu.tar.xz
$(package)_sha256_hash_aarch64_linux=8c2f4d1606d24dc197a590acce39453abe7a302b9b92e762108f9b5a9701b1df
$(package)_download_file_linux=clang+llvm-$($(package)_version)-x86_64-linux-gnu-ubuntu-22.04.tar.xz
$(package)_file_name_linux=clang-llvm-$($(package)_version)-x86_64-linux-gnu-ubuntu-22.04.tar.xz
$(package)_sha256_hash_linux=1607375b4aa2aec490b6db51846a04b265675a87e925bcf5825966401ff9b0b1

# Starting from LLVM 14.0.0, some Clang binary tarballs store libc++ in a
# target-specific subdirectory.
define $(package)_stage_cmds
  mkdir -p $($(package)_staging_prefix_dir)/lib && \
  (test ! -f lib/*/libc++.a    || cp lib/*/libc++.a    $($(package)_staging_prefix_dir)/lib) && \
  (test ! -f lib/*/libc++abi.a || cp lib/*/libc++abi.a $($(package)_staging_prefix_dir)/lib) && \
  (test ! -f lib/libc++.a      || cp lib/libc++.a      $($(package)_staging_prefix_dir)/lib) && \
  (test ! -f lib/libc++abi.a   || cp lib/libc++abi.a   $($(package)_staging_prefix_dir)/lib)
endef

else
# For Windows cross-compilation, use the MSYS2 binaries.
# Starting from LLVM 15.0.0, libc++abi is provided by libc++.
$(package)_download_path=https://repo.msys2.org/mingw/x86_64
$(package)_download_file=mingw-w64-x86_64-libc++-$($(package)_msys2_version)-any.pkg.tar.zst
$(package)_file_name=mingw-w64-x86_64-libcxx-$($(package)_msys2_version)-any.pkg.tar.zst
$(package)_sha256_hash=45f8dcac0ed5ff68d202c9321375dbefb0a7e7aa1d1e1ed7299842759f9bc88b

define $(package)_stage_cmds
  mkdir -p $($(package)_staging_prefix_dir)/lib && \
  mv include/ $($(package)_staging_prefix_dir) && \
  cp lib/libc++.a $($(package)_staging_prefix_dir)/lib && \
  cp lib/libc++abi.a $($(package)_staging_prefix_dir)/lib
endef
endif

else
# For native compilation, use the static libraries from native_clang.
# We explicitly stage them so that subsequent dependencies don't link to the
# shared libraries distributed with Clang.
define $(package)_fetch_cmds
endef

define $(package)_extract_cmds
endef

define $(package)_stage_cmds
  mkdir -p $($(package)_staging_prefix_dir)/lib && \
  (test ! -f $(build_prefix)/lib/*/libc++.a    || cp $(build_prefix)/lib/*/libc++.a    $($(package)_staging_prefix_dir)/lib) && \
  (test ! -f $(build_prefix)/lib/*/libc++abi.a || cp $(build_prefix)/lib/*/libc++abi.a $($(package)_staging_prefix_dir)/lib) && \
  (test ! -f $(build_prefix)/lib/libc++.a      || cp $(build_prefix)/lib/libc++.a      $($(package)_staging_prefix_dir)/lib) && \
  (test ! -f $(build_prefix)/lib/libc++abi.a   || cp $(build_prefix)/lib/libc++abi.a   $($(package)_staging_prefix_dir)/lib)
endef

endif
