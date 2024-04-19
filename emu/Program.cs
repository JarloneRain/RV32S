using RV32Semu;

var src = "/home/looooong/RV32S/tests";

Tracer tracer = new();
CPU cpu = new CPU(tracer);


cpu.Init($"{src}/{args[0]}.bin");
tracer.Init($"{src}/{args[0]}.txt");


try
{
    while (true)
    {
        Console.Write(@"RV32S emulator
    c    : continue executing
    x N  : execute N instructions
    t N  : show N trace
    r    : print regs
    q    : quit
");
        string cmd = Console.ReadLine() ?? "";
        switch (cmd[0])
        {
            case 'c':
                cpu.Exec(int.MaxValue);
                break;
            case 'x':
                cpu.Exec(int.Parse(cmd[2..]));
                break;
            case 't':
                tracer.Print(uint.Parse(cmd[2..]));
                break;
            case 'r':
                cpu.PrintGpr();
                break;
            case 'q':
                return;
            default:
                Console.ForegroundColor = ConsoleColor.DarkRed;
                Console.WriteLine("Unknow coomand.");
                Console.ResetColor();
                break;
        }
    }
}
catch (Ebreak)
{
    Console.ForegroundColor = ConsoleColor.Green;
    Console.WriteLine("SUCCESS!");
    Console.ResetColor();
}
catch (Exception e)
{
    tracer.Print(16);
    cpu.PrintGpr();
    Console.WriteLine(e);
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine("FAIL!");
    Console.ResetColor();
}
finally
{
}