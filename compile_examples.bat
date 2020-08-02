@echo off
setlocal


pushd examples
for %%i in (*.jai) do jai -x64 %%i
popd