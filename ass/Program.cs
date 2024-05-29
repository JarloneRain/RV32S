var target = args[0];
var src = args[1];
var build = args[2];
var tracerOn = false;
for (int i = 2; i < args.Length; i++)
{
        var arg = args[i];
        if (arg == "-t")
        {
                tracerOn = true;
        }
}

if (!Directory.Exists(build)) Directory.CreateDirectory(build);

var assember = new Ass.Assember();
assember.Assemble(File.ReadAllLines($"{src}/{target}.s")).WriteBin($"{build}/{target}.bin");
if (tracerOn) assember.WriteText($"{build}/{target}.txt");