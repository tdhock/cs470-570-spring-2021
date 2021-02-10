import code
class FileConsole(code.InteractiveConsole):
    """Emulate python console but use file instead of stdin"""
    def raw_input(self, prompt):
        line = self.f.readline()
        if line=="":
            raise EOFError()
        no_newline = line.replace("\n", "")
        print(prompt, no_newline, sep="")
        return no_newline
    
def run_file(filename):
    fc = FileConsole()
    fc.f = open(filename)
    fc.interact(banner="", exitmsg="")

if __name__ == "__main__":
    import sys
    sys.ps1 = "\n>>> "
    run_file(sys.argv[1])

