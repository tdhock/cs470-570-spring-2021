import code
class FileConsole(code.InteractiveConsole):
    """Emulate python console but use file instead of stdin"""
    def raw_input(self, prompt):
        line = f.readline()
        if line=="":
            raise EOFError()
        print(prompt, line.replace("\n", ""))
        return line
import sys
sys.ps1 = "\n>>>"
f = open(sys.argv[1])
FileConsole().interact(banner="", exitmsg="")

