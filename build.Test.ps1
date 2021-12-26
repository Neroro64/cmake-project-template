BeforeAll {
    . cmake.ps1
}

# Pester tests
Describe 'Invoke-CmakeTest' {
  It "Checking Invoke-CMakeHeader" {
    Invoke-CMakeHeader;
  }

  Context "Checking Invoke-CmakeBuild" {
    It "Testing PreMake" {
      Write-Host "TEST Cleaning output folders"
      Invoke-Expression "rm -Recurse -Force bin/d*, include/d*, lib/*"
      if (Test-Path -Path build){
        Invoke-Expression "rm -Recurse -Force build"
      }

      Write-Host "TEST Creating Build folder..."
      Invoke-Expression "mkdir -p build/debug"
      Invoke-Expression "git submodule init; git submodule update"
      Test-Path -Path "build/debug" | Should -Be $true
    }
    It "Testing cmake MSVC generator" {
      Invoke-Expression "cd build/debug"
      Invoke-Expression "cmake -G'MSVC' ../.."

	    Invoke-Expression "cd ../.."
      Remove-Item -Recurse -Force build
    }
    It "Testing cmake Unix generator" {
      Invoke-Expression "cd build/debug"
      Invoke-Expression "cmake -G'Unix Makefiles' ../.."
      Test-Path -Path cmake_install.cmake | Should -Be $true
      Test-Path -Path Makefile | Should -Be $true
    }
    It "Testing Make" {
      Invoke-Expression "make -j $((Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors / 2)" | Tee-Object -FilePath .log
      Invoke-Expression "make install" | Tee-Object -FilePath .log
      
      Test-Path -Path "compile_commands.json" | Should -Be $true
      $executables = fd -u -e "exe" . src   # find all .exe files inside src
      $symbols = fd -u -e "pdb" . src   # find all .pdb files inside src

      ($executables.Length -gt 0 -and $symbols.Length -eq $executables.Length) | Should -Be $true

	    Invoke-Expression "cd ../.."
      Remove-Item -Recurse -Force build
    }
    It "Testing testing"{
      $test_executables = fd -u -e "exe" "[Tt]ests?" bin
      $test_executables.Length | Should -BeGreaterThan 0
      Invoke-Expression "git checkout ."  # Undo every changes
    }
  }
}