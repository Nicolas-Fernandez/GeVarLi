# main.py
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from rich.table import Table

def display_welcome_screen():
    """
    Displays the welcome screen for GeVarLi CLI.
    """
    console = Console()

    # ASCII art for GeVarLi (simple example)
    gevarli_logo = Text("""
    ██████╗ ███████╗██╗   ██╗ █████╗ ██████╗ ██╗     ██╗
    ██╔════╝ ██╔════╝██║   ██║██╔══██╗██╔══██╗██║     ██║
    ██║  ███╗█████╗  ██║   ██║███████║██████╔╝██║     ██║
    ██║   ██║██╔══╝  ██║   ██║██╔══██║██╔══██╗██║     ██║
    ╚██████╔╝███████╗╚██████╔╝██║  ██║██║  ██║███████╗██║
     ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝
    """, style="bold bright_cyan")

    console.print(gevarli_logo)

    console.print(Panel(
        Text("Welcome to GeVarLi Command Line Interface!", justify="center", style="bold green"),
        title="[bold yellow]GeVarLi CLI[/bold yellow]",
        subtitle="[dim white]Your powerful variant analysis tool[/dim white]",
        border_style="blue"
    ))

    console.print("\n[bold]Current Configuration:[/bold]")
    config_table = Table(show_header=False, show_lines=False, border_style="dim")
    config_table.add_column("Setting", style="bold magenta")
    config_table.add_column("Value", style="cyan")

    # In a real application, you'd load this from a config file
    config_table.add_row("Version", "1.0.0-beta")
    config_table.add_row("Data Path", "/path/to/data")
    config_table.add_row("Log Level", "INFO")

    console.print(config_table)

    console.print("\n[bold]Available Commands:[/bold]")
    console.print("  [green]config[/green]    - Configure GeVarLi settings")
    console.print("  [green]run[/green]       - Start a variant analysis")
    console.print("  [green]report[/green]    - Generate analysis reports")
    console.print("  [green]help[/green]      - Show this help message")
    console.print("  [green]exit[/green]      - Exit the application")

    console.print("\n[dim italic]Press 'h' for help or 'q' to quit.[/dim italic]")

if __name__ == "__main__":
    display_welcome_screen()
