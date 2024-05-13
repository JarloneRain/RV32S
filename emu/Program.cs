using System.Globalization;

var build = "/home/looooong/RV32S/tests/build";

string target=args[0];

RV32Semu.Tracer tracer = new() { TracerOn = true };
RV32Semu.Cpu cpu = new RV32Semu.CpuWithTracer(new RV32Semu.Decoder(), new RV32Semu.Gpr(),
                    new RV32Semu.MemoryWithTracer(tracer), tracer);

cpu.Init($"{build}/{target}.bin");
tracer.Init($"{build}/{target}.txt");

try
{
    PrintLogo();
    PrintHelp();
    while (true)
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
                        cpu.Exec(int.Parse(input[1]));
                    else goto default;
                    break;
                case "t":
                    if (input.Length == 2
                        && uint.TryParse(input[1], out uint n))
                        tracer.Print(n);
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