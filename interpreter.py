import code, sys, fileinput
sys.ps1 = "\n>>>"
fi = fileinput.input(sys.argv[1])
class FileConsole(code.InteractiveConsole):
    """Emulate python console but use file instead of stdin"""
    def raw_input(self, prompt):
        l = fi.readline()
        if l=="":
            raise EOFError()
        print(prompt, l.replace("\n", ""))
        return l
fc = FileConsole()
fc.interact(banner="", exitmsg="")

