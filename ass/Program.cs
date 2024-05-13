var build = @"/home/looooong/RV32S/tests/build";
var src = @"/home/looooong/RV32S/tests";
var target = args[0];

if(!Directory.Exists(build)) Directory.CreateDirectory(build);

var assember = new Ass.Assember();
assember.Assemble(File.ReadAllLines($"{src}/{target}.s"))
        .WriteBin($"{build}/{target}.bin")
        .WriteText($"{build}/{target}.txt");