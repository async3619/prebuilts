@echo off

set GIT_FETCH_JOBS=8

git clone --depth 1 -b master https://github.com/boostorg/boost
cd ./boost

git submodule init tools/build tools/boostdep tools/boost_install libs/headers libs/config libs/filesystem
git submodule update --jobs %GIT_FETCH_JOBS%

python tools/boostdep/depinst/depinst.py --git_args "--jobs %GIT_FETCH_JOBS%" filesystem

cmd /c .\bootstrap.bat

set "BUILD_OPTION= toolset=msvc-14.1 link=static runtime-link=static threading=multi warnings=off"
set "BUILD_OPTION= %BUILD_OPTION% define=BOOST_TYPE_INDEX_FORCE_NO_RTTI_COMPATIBILITY"

IF "%CONFIGURATION%"=="Debug" (
    set "BUILD_OPTION= %BUILD_OPTION% variant=debug debug-symbols=on optimization=off"
) ELSE (
    set "BUILD_OPTION= %BUILD_OPTION% variant=release debug-symbols=off optimization=speed"
)

REM build first
.\b2.exe -a %BUILD_OPTION% address-model=32,64 stage

REM then install it into separated path
.\b2.exe -d0 -j4 --prefix=./%BRANCH_NAME%-x86 address-model=32 %BUILD_OPTION% install
.\b2.exe -d0 -j4 --prefix=./%BRANCH_NAME%-x64 address-model=64 %BUILD_OPTION% install

REM get boost versioning name to interpolate path
powershell -c "Set-Content .boost_version (Get-ChildItem .\%BRANCH_NAME%-x86\include\)[0].Name"
set /p BOOST_VERSIONING= < .boost_version

REM interpolate path
powershell -c "Move-Item .\%BRANCH_NAME%-x86\include\%BOOST_VERSIONING%\boost .\%BRANCH_NAME%-x86\include\boost"
powershell -c "Remove-Item .\%BRANCH_NAME%-x86\include\%BOOST_VERSIONING%"

powershell -c "Move-Item .\%BRANCH_NAME%-x64\include\%BOOST_VERSIONING%\boost .\%BRANCH_NAME%-x64\include\boost"
powershell -c "Remove-Item .\%BRANCH_NAME%-x64\include\%BOOST_VERSIONING%"

cd ..