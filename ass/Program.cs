var src = @"/home/looooong/RV32S/tests";

var assember = new Ass.Assember();
assember.Assemble(File.ReadAllLines($"{src}/{args[0]}.s"))
        .WriteBin($"{src}/{args[0]}.bin")
        .WriteText($"{src}/{args[0]}.txt");