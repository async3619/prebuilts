@echo off

set GIT_FETCH_JOBS=8

git clone --depth 1 -b master https://github.com/boostorg/boost
cd ./boost

git submodule init tools/build tools/boostdep tools/boost_install libs/headers libs/config libs/filesystem
git submodule update --jobs %GIT_FETCH_JOBS% --depth 1

python tools/boostdep/depinst/depinst.py --git_args "--jobs %GIT_FETCH_JOBS% --depth 1" filesystem

cmd /c .\bootstrap.bat

REM build first
.\b2.exe^
 toolset=msvc-14.0^
 address-model=32,64^
 link=static^
 runtime-link=static^
 variant=release^
 debug-symbols=off^
 optimization=speed^
 threading=multi^
 warnings=off^
 stage

REM then install it into separated path
.\b2.exe^
 -d0^
 -j4^
 --prefix=./%BRANCH_NAME%-x86^
 toolset=msvc-14.0^
 address-model=32^
 link=static^
 runtime-link=static^
 variant=release^
 debug-symbols=off^
 optimization=speed^
 threading=multi^
 warnings=off^
 install

.\b2.exe^
 -d0^
 -j4^
 --prefix=./%BRANCH_NAME%-x64^
 toolset=msvc-14.0^
 address-model=64^
 link=static^
 runtime-link=static^
 variant=release^
 debug-symbols=off^
 optimization=speed^
 threading=multi^
 warnings=off^
 install

REM get boost versioning name to interpolate path
powershell -c "Set-Content .boost_version (Get-ChildItem .\boost-x86\include\)[0].Name"
set /p BOOST_VERSIONING= < .boost_version

REM interpolate path
powershell -c "Move-Item .\boost-x86\include\%BOOST_VERSIONING%\boost .\boost-x86\include\boost"
powershell -c "Remove-Item .\boost-x86\include\%BOOST_VERSIONING%"

powershell -c "Move-Item .\boost-x64\include\%BOOST_VERSIONING%\boost .\boost-x86\include\boost"
powershell -c "Remove-Item .\boost-x64\include\%BOOST_VERSIONING%"

cd ..