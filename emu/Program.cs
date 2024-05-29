using System.Globalization;

string target = args[0];
bool tracerOn = false;
bool continueMode = false;

for (int i = 1; i < args.Length; i++)
{
    string arg = args[i];
    if (arg == "-t")
    {
        tracerOn = true;
    }
    if (arg == "-c")
    {
        continueMode = true;
    }
}

RV32Semu.Tracer tracer = new() { TracerOn = tracerOn };
RV32Semu.Cpu cpu;

if (tracerOn)
{
    cpu = new RV32Semu.CpuWithTracer(
            new RV32Semu.Decoder(),
            new RV32Semu.Gpr(),
            new RV32Semu.MemoryWithTracer(tracer),
            tracer);
    tracer.Init($"{target}.txt");
}
else
{
    cpu = new RV32Semu.Cpu(
            new RV32Semu.Decoder(),
            new RV32Semu.Gpr(),
            new RV32Semu.Memory());

}

cpu.Init($"{target}.bin");

try
{
    if (!continueMode)
    {
        PrintLogo();
        PrintHelp();
    }
    while (!continueMode)
    {
        string[] input = Console.ReadLine()?.Split(' ') ?? [];
        if (input.Length == 0) continue;
        try
        {
            switch (input[0])
            {
                case "c":
                    cpu.Exec(int.MaxValue);
                    break;
                case "x":
                    if (input.Length == 2
                        && int.TryParse(input[1], out int t))
                        cpu.Exec(t);
                    else goto default;
                    break;
                case "t":
                    if (input.Length == 2)
                        if (uint.TryParse(input[1], out uint n))
                            tracer.Print(n);
                        else
                            File.WriteAllText(input[1], tracer.TraceText);
                    else goto default;
                    break;
                case "r":
                    cpu.PrintGpr();
                    break;
                case "m":
                    if (input.Length == 3
                        && uint.TryParse(input[1], NumberStyles.HexNumber, CultureInfo.InvariantCulture, out uint addr)
                        && uint.TryParse(input[2], out uint words))
                        cpu.PrintMem(addr, words);
                    else goto default;
                    break;
                case "h":
                    PrintHelp();
                    break;
                case "q":
                    return;
                default:
                    Console.ForegroundColor = ConsoleColor.DarkRed;
                    Console.WriteLine("Please check your input.");
                    Console.ResetColor();
                    PrintHelp();
                    break;
            }
        }
        catch (RV32Semu.Ebreak)
        {
            cpu.IsFinish = true;
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("SUCCESS!");
            Console.ResetColor();
        }
        catch (RV32Semu.Ecall)
        {
            cpu.IsFinish = true;
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine("FAIL!");
            Console.ResetColor();
        }
        catch (RV32Semu.CpuFinishException)
        {
            Console.ForegroundColor = ConsoleColor.DarkRed;
            Console.WriteLine("Cpu has finished.");
            Console.ResetColor();
        }
    }
    // for continue mode
    try
    {
        cpu.Exec(int.MaxValue);
    }
    catch (RV32Semu.Ebreak)
    {
        cpu.IsFinish = true;
        Console.ForegroundColor = ConsoleColor.Green;
        Console.WriteLine("SUCCESS!");
        Console.ResetColor();
    }
    catch (RV32Semu.Ecall)
    {
        cpu.IsFinish = true;
        Console.ForegroundColor = ConsoleColor.Red;
        Console.WriteLine("FAIL!");
        Console.ResetColor();
    }
    catch (Exception)
    {
        throw;
    }
}
catch (Exception e)
{
    tracer.Print(16);
    cpu.PrintGpr();
    Console.ForegroundColor = ConsoleColor.DarkRed;
    Console.WriteLine(e);
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine("FAIL!");
    Console.ResetColor();
}
finally
{
}


static void PrintHelp()
{
    Console.Write(@"Commands:
    c     : continue executing
    x N   : execute N instructions
    t N   : show N trace
    t F   : save trace to file F
    r     : print regs
    m A N : print N words from addr in memory
    h     : help
    q     : quit
");
}

static void PrintLogo()
{
    Console.WriteLine(@"
          _____            _____                    _____                    _____          
         /\    \          /\    \                  /\    \                  /\    \         
        /::\____\        /::\    \                /::\____\                /::\____\        
       /:::/    /       /::::\    \              /::::|   |               /:::/    /        
      /:::/    /       /::::::\    \            /:::::|   |              /:::/    /         
     /:::/    /       /:::/\:::\    \          /::::::|   |             /:::/    /          
    /:::/    /       /:::/__\:::\    \        /:::/|::|   |            /:::/    /           
   /:::/    /       /::::\   \:::\    \      /:::/ |::|   |           /:::/    /            
  /:::/    /       /::::::\   \:::\    \    /:::/  |::|___|______    /:::/    /      _____  
 /:::/    /       /:::/\:::\   \:::\    \  /:::/   |::::::::\    \  /:::/____/      /\    \ 
/:::/____/       /:::/__\:::\   \:::\____\/:::/    |:::::::::\____\|:::|    /      /::\____\
\:::\    \       \:::\   \:::\   \::/    /\::/    / ~~~~~/:::/    /|:::|____\     /:::/    /
 \:::\    \       \:::\   \:::\   \/____/  \/____/      /:::/    /  \:::\    \   /:::/    / 
  \:::\    \       \:::\   \:::\    \                  /:::/    /    \:::\    \ /:::/    /  
   \:::\    \       \:::\   \:::\____\                /:::/    /      \:::\    /:::/    /   
    \:::\    \       \:::\   \::/    /               /:::/    /        \:::\__/:::/    /    
     \:::\    \       \:::\   \/____/               /:::/    /          \::::::::/    /     
      \:::\    \       \:::\    \                  /:::/    /            \::::::/    /      
       \:::\____\       \:::\____\                /:::/    /              \::::/    /       
        \::/    /        \::/    /                \::/    /                \::/____/        
         \/____/          \/____/                  \/____/                  ~~              
                An emulator for RV32IFS ISA. Implemented by Looooong.
");
}