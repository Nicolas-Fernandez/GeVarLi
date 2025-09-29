import os
import yaml
from prompt_toolkit import Application
from prompt_toolkit.layout.containers import VSplit, Window, HSplit, ConditionalContainer
from prompt_toolkit.layout.controls import FormattedTextControl
from prompt_toolkit.layout.layout import Layout
from prompt_toolkit.key_bindings import KeyBindings
from prompt_toolkit.styles import Style
from prompt_toolkit.widgets import Frame, RadioList, TextArea, Button, Label, Box
from prompt_toolkit.layout.dimension import D
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from rich.table import Table

# --- Global Variables and Configuration Paths ---
CONFIG_FILE_PATH = 'config.yaml' # Path to the main configuration file

# --- ASCII Art Logo for GeVarLi (from config.yaml header) ---
GEVARLI_ASCII_LOGO = """
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\\     ###
###    ||  \\ \\ \\ \\    / __( ___( \\/ )__\\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \\  /(__)\\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \\___(____) \\(__)(__(_)\\_(____(____)   \\_\\_\\_\\  ||     ###
###    \\/                                                            \\/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
"""

# --- Styles for the CLI Application ---
style = Style.from_dict({
    'dialog': 'bg:#88ff88 #ffffff',
    'button': 'bg:#444444 #ffffff',
    'button.focused': 'bg:#ffcc00 #000000',
    'text-area': 'bg:#222222 #ffffff',
    'radio-list': 'bg:#333333 #ffffff',
    'radio-list.focused': 'bg:#555555 #ffffff',
    'radio-list.checked': 'bg:#00aa00 #ffffff',
    'label': 'bg:#1a1a1a #aaaaaa',
    'title': 'bold #00ff00',
    'header': 'bold #00ffff',
    'message': '#ffffff',
    'selected-item': 'bold #ffcc00', # Style for selected item in menu
    'default': '#ffffff' # Default text color
})

# --- Application State and Configuration Loading ---
class AppState:
    """Manages the application state, including loaded configuration."""
    def __init__(self):
        self.config_data = {}
        self.load_config()
        self.current_screen = 'main_menu' # 'main_menu', 'config_menu', 'run_analysis'
        self.config_section_index = 0
        self.config_fields = [] # List of (key, type, options) for the current section
        self.config_field_index = 0
        self.current_field_input = ''
        self.message = '' # Global message display
        self.show_message_box = False

    def load_config(self):
        """Loads configuration from config.yaml."""
        try:
            with open(CONFIG_FILE_PATH, 'r') as f:
                self.config_data = yaml.safe_load(f)
            self.message = "Configuration loaded successfully."
        except FileNotFoundError:
            self.message = f"Error: '{CONFIG_FILE_PATH}' not found."
            self.config_data = {}
        except yaml.YAMLError as e:
            self.message = f"Error parsing '{CONFIG_FILE_PATH}': {e}"
            self.config_data = {}
        self.show_message_box = True

    def save_config(self):
        """Saves configuration to config.yaml."""
        try:
            with open(CONFIG_FILE_PATH, 'w') as f:
                yaml.dump(self.config_data, f, default_flow_style=False, sort_keys=False)
            self.message = "Configuration saved successfully!"
        except Exception as e:
            self.message = f"Error saving configuration: {e}"
        self.show_message_box = True

    def get_config_value(self, path, default=None):
        """
        Retrieves a nested value from the config data.
        Path is a list of keys, e.g., ['modules', 'qualities']
        """
        value = self.config_data
        try:
            for key in path:
                value = value[key]
            return value
        except (KeyError, TypeError):
            return default

    def set_config_value(self, path, new_value):
        """
        Sets a nested value in the config data.
        Path is a list of keys.
        """
        target = self.config_data
        for i, key in enumerate(path):
            if i == len(path) - 1:
                target[key] = new_value
            else:
                if key not in target:
                    target[key] = {}
                target = target[key]


# --- Menu Navigation Logic ---
def get_main_menu_items():
    return [
        ("Configure GeVarLi", "config_menu"),
        ("Run Analysis", "run_analysis"),
        ("View Status", "view_status"),
        ("Exit", "exit_app")
    ]

# --- UI Components ---
class MessageBox:
    """A simple message box widget."""
    def __init__(self, app_state, on_ok=None):
        self.app_state = app_state
        self.on_ok = on_ok
        self.ok_button = Button(" OK ", handler=self._on_ok_clicked)

        self.body = HSplit([
            Label(lambda: app_state.message, style="message"),
            Window(height=1, char=' '), # Spacer
            Window(content=self.ok_button, align="center")
        ], width=D(preferred=80), height=D(preferred=5)) # Fixed size for dialog

        self.frame = Frame(self.body, title="Message", style="dialog")

    def _on_ok_clicked(self):
        self.app_state.show_message_box = False
        if self.on_ok:
            self.on_ok()

    def __pt_container__(self):
        return self.frame

def get_main_menu_ui(app_state, app):
    """Generates the main menu UI."""
    menu_items = get_main_menu_items()
    selected_index = 0 # This needs to be managed by app_state for persistent selection

    def get_menu_text():
        lines = []
        for i, (text, action) in enumerate(menu_items):
            if i == app_state.menu_index: # Assuming app_state.menu_index exists
                lines.append(f"> {text}")
            else:
                lines.append(f"  {text}")
        return "\n".join(lines)

    menu_control = FormattedTextControl(
        text=lambda: "\n".join([
            (f'[selected-item]> {item[0]}' if i == app_state.menu_index else f'  {item[0]}')
            for i, item in enumerate(menu_items)
        ])
    )

    return HSplit([
        Window(content=FormattedTextControl(GEVARLI_ASCII_LOGO, style="header")),
        Window(height=1, char=' '), # Spacer
        Frame(
            Window(content=menu_control, height=D(max_content=True), cursorline=True),
            title="[title]Main Menu[/title]"
        ),
        Window(height=1, char=' '), # Spacer
        Label(text="Use [Up/Down] arrows to navigate, [Enter] to select.", style="label")
    ], width=D(preferred=80, max=80, min=80), height=D(preferred=20))

def get_config_menu_ui(app_state, app):
    """Generates the configuration menu UI."""
    def get_config_section_list():
        # Dynamically get top-level sections from config_data
        sections = list(app_state.config_data.keys())
        # Filter out "I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####"
        sections = [s for s in sections if not s.startswith("###I###R###D")]
        return [(section, section) for section in sections]

    sections = get_config_section_list()
    current_section_name = sections[app_state.config_section_index][0] if sections else "No Section"

    # Define how to display different types of config values
    def get_field_input_ui(field_key, field_value, field_type, field_options=None):
        current_path = app_state.current_config_path + [field_key] # Full path for the field

        if field_type == 'bool':
            # Use RadioList for boolean (true/false)
            initial_value = 'true' if app_state.get_config_value(current_path, False) else 'false'
            radio_list = RadioList(
                values=[('true', 'true'), ('false', 'false')],
                default_value=initial_value
            )
            def _on_change(rb_list):
                new_bool_val = (rb_list.current_value == 'true')
                app_state.set_config_value(current_path, new_bool_val)
                app_state.message = f"Set {field_key} to {new_bool_val}"
                app_state.show_message_box = True

            radio_list.on_change = _on_change
            return radio_list
        elif field_options:
            # Use RadioList for options from a list of comments
            # Extract actual values from comments
            values = []
            for opt_str in field_options:
                match = re.search(r"'(.*?)'", opt_str)
                if match:
                    values.append((match.group(1), match.group(1))) # (value, label)
                else:
                    values.append((opt_str, opt_str)) # Fallback if no quote found

            initial_value = str(app_state.get_config_value(current_path, "")) # Ensure string
            radio_list = RadioList(
                values=values,
                default_value=initial_value
            )
            def _on_change(rb_list):
                app_state.set_config_value(current_path, rb_list.current_value)
                app_state.message = f"Set {field_key} to {rb_list.current_value}"
                app_state.show_message_box = True

            radio_list.on_change = _on_change
            return radio_list
        elif field_type == 'str' or field_type == 'int' or field_type == 'float' or field_type == 'path':
            # Use TextArea for string/numeric input
            text_area = TextArea(
                text=str(app_state.get_config_value(current_path, "")),
                multiline=False,
                width=D(preferred=40),
                style="text-area"
            )
            def _on_change(ta):
                try:
                    val = ta.text
                    if field_type == 'int':
                        val = int(val)
                    elif field_type == 'float':
                        val = float(val)
                    app_state.set_config_value(current_path, val)
                    app_state.message = f"Set {field_key} to {val}"
                    app_state.show_message_box = True
                except ValueError:
                    app_state.message = f"Invalid input for {field_key}. Expected {field_type}."
                    app_state.show_message_box = True
                except Exception as e:
                    app_state.message = f"Error updating {field_key}: {e}"
                    app_state.show_message_box = True
            text_area.buffer.on_text_changed += _on_change
            return text_area
        else:
            return Label(text=f"Unsupported type: {field_type}", style="red")

    config_content_widgets = []
    if sections:
        # Get fields for the selected section
        app_state.current_config_path = [current_section_name]
        section_data = app_state.config_data.get(current_section_name, {})

        # Parse config section to get fields and their types/options
        app_state.config_fields = []
        if isinstance(section_data, dict):
            for key, value in section_data.items():
                if isinstance(value, dict) and 'path' in value and 'scheme' in value:
                     # Special handling for nested structures like primers.bed
                    sub_path = app_state.current_config_path + [key]
                    sub_section_data = app_state.config_data.get(current_section_name, {}).get(key, {})
                    for sub_key, sub_value in sub_section_data.items():
                        # Read comments for available options
                        options = []
                        if isinstance(sub_value, str): # Assume comments are for string options
                            # Look for comments in the original config.yaml (this is tricky with just parsed YAML)
                            # For a robust solution, you'd need a YAML parser that retains comments or a custom parser.
                            # For now, let's simulate based on common patterns in your config.yaml
                            if sub_key == 'scheme':
                                # Hardcode options based on the provided config.yaml for 'scheme'
                                options = [
                                    "##- 'nCoV-2019/V5.3.2/SARS-CoV-2.primer.bed' # SARS-CoV-2 Artic V5.3.2 (latest)",
                                    "##- 'nCoV-2019/V4.1/SARS-CoV-2.primer.bed'   # SARS-CoV-2 Artic V4.1 (update to the V4, see Artic README)",
                                    "##- 'nCoV-2019/V4/SARS-CoV-2.primer.bed'     # SARS-CoV-2 Artic V4 (not based on V3, see Artic README)",
                                    "##- 'nCoV-2019/V3/SARS-CoV-2.primer.bed'     # SARS-CoV-2 Artic V3",
                                    "##- 'nCoV-2019/V2/SARS-CoV-2.primer.bed'     # SARS-CoV-2 Artic V2",
                                    "##- 'nCoV-2019/V1/SARS-CoV-2.primer.bed'     # SARS-CoV-2 Artic V1",
                                    "##- 'ZaireEbola/V3/ZaireEbola.primer.bed'    # EBOV Artic V3",
                                    "##- 'ZaireEbola/V2/ZaireEbola.primer.bed'    # EBOV Artic V2 (based on AF272001.1)",
                                    "##- 'ZaireEbola/V1/ZaireEbola.primer.bed'    # EBOV Artic V1",
                                    "##- 'Nipah/V1/NiV_6_Malaysia.primer.bed'     # NIV Artic V1",
                                    "##- 'MPXV/V1/MPXV.primer.bed'                # MPXV  V1 (dx.doi.org/10.17504/protocols.io.5qpvob1nbl4o/v4)",
                                    "##- 'your_custom_amplicon_kit.bed'           # Add your custom amplicon kit"
                                ]
                        app_state.config_fields.append((key, sub_key, 'str', options)) # Nested field
                else:
                    # Regular field
                    field_type = 'str' # Default type
                    options = None
                    if isinstance(value, bool):
                        field_type = 'bool'
                    elif isinstance(value, int):
                        field_type = 'int'
                    elif isinstance(value, float):
                        field_type = 'float'
                    elif key in ['fastq_dir', 'path', 'tmp_dir']: # Heuristics for path types
                        field_type = 'path'

                    # Check for commented options in config.yaml for 'tools', 'consensus', 'nextclade', 'primers', 'bwa', 'bowtie2', 'minimap2', 'sickle_trim', 'cutadapt', 'multiqc', 'fastq_screen', 'report'
                    if key == 'mapper':
                        options = [
                            "#- 'bwa'      # Better, faster (default)",
                            "#- 'bowtie2'  # Slower, 'sensitivity' requiried (see below 'Bowtie2' options)",
                            "#- 'minimap2' # Versatile"
                        ]
                    elif key == 'caller':
                        options = [
                            "#- 'ivar' # iVar: a toolkit for analysis of viral NGS data (default)"
                        ]
                    elif key == 'assigner':
                        options = [
                            "#- 'nextclade' # Clade assignment, mutation calling, phylogenetic placement and quality checks (default)",
                            "#- 'pangolin'  # PANGO: Phylogenetic Assignment of Named Global Outbreak Lineages"
                        ]
                    elif key == 'reference':
                        options = [
                            "#- 'MN908947' # [SARS-CoV-2] : Severe acute respiratory syndrome coronavirus 2 (default)",
                            "#- 'NC045512' # [SARS-CoV-2] : Severe acute acute respiratory syndrome coronavirus 2",
                            "##",
                            "#- 'AF380138' # [MPXV] : Monkeypox virus Zaire",
                            "#- 'MT903345' # [MPXV] : Monkeypox virus UK",
                            "#- 'MW036632' # [SPXV] : Swinepox India"
                            # ... and so on for other references from config.yaml
                        ]
                    elif key == 'min_depth':
                        options = [
                            "#- '100' # 100 X : for greater coverage",
                            "#- '60'  #  30 X : for better coverage",
                            "#- '30'  #  30 X : for AFROSCREEN SARS-CoV-2 consortium, with Illumina amplicons sequencing (recomanded)",
                            "#- '10'  #  10 X : for some applications (default)",
                            "#- '3'   #   3 X : only for exploration...",
                            "#- '1'   #   1 X : not recommanded!"
                        ]
                    elif key == 'map_qual':
                        options = [
                            "##- '--no-BAQ' # no, don't merge mapping quality: disable (default, recommanded with Samtools)",
                            "##- ''         # yes, merge mapping quality: enable (not recommanded with Samtools)"
                        ]
                    elif key == 'dataset' and current_section_name == 'nextclade':
                        options = [
                            "##- 'sars-cov-2' # SARS-CoV-2 (default)",
                            "##- 'MPXV'       # MPox - all clades",
                            "##- 'hMPXV'      # human MPox",
                            "##- 'hMPXV_B1'   # human MPox - only lineage B1*"
                        ]
                    elif key == 'algorithm' and current_section_name == 'bwa':
                        options = [
                            "##- ''         # Auto-select (default)",
                            "##- '-a is'    # Moderately fast, but does not work with database larger than 2GB",
                            "##- '-a bwtsw' # This method works with the whole human genome"
                        ]
                    elif key == 'sensitivity' and current_section_name == 'bowtie2':
                        options = [
                            "##- '--very-sensitive' # Same as options: \"-D 20 -R 3 -N 0 -L 20 -i S,1,0.50\" (default)",
                            "##- '--sensitive'      # Same as options: \"-D 15 -R 2 -N 0 -L 22 -i S,1,1.15\"",
                            "##- '--fast'           # Same as options: \"-D 10 -R 2 -N 0 -L 22 -i S,0,2.50\"",
                            "##- '--very-fast'      # Same as options: \"-D 5 -R 1 -N 0 -L 22 -i S,0,2.50\""
                        ]
                    elif key == 'preset' and current_section_name == 'minimap2':
                         options = [
                            "##- 'sr'        # genomic short-read mapping, like Illumina (default)",
                            "##- 'map-ont'   # Nanopore vs reference mapping",
                            "##- 'ava-ont'   # Nanopore read overlap",
                            "##- 'splice'    # Long-read spliced alignment",
                            "##- 'map-pb'    # PacBio vs reference mapping",
                            "##- 'map-hifi'  # PacBio HiFi reads vs reference mapping",
                            "##- 'ava-pb'    # PacBio read overlap",
                            "##- 'splice:hq' # Pacbio-CCS spliced alignment",
                            "##- 'asm5'      # asm-to-ref mapping, for ~0.1% sequence divergence",
                            "##- 'asm10'     # asm-to-ref mapping, for ~1.0% sequence divergence",
                            "##- 'asm20'     # asm-to-ref mapping, for ~5.0% sequence divergence"
                        ]
                    elif key == 'command' and current_section_name == 'sickle_trim':
                        options = [
                            "#- 'pe'      # Reading (default and should be \"pe\" for paired-end sequences)"
                        ]
                    elif key == 'encoding' and current_section_name == 'sickle_trim':
                        options = [
                            "###- 'sanger'   # for CASAVA >= 1.8 for \"recent\" Illumina reads (default)",
                            "###- 'illumina' # for CASAVA 1.3 to 1.7 for \"old\" Illumina reads",
                            "###- 'solexa'   # for CASAVA < 1.3 for Solexa"
                        ]
                    elif key == 'adapters' and current_section_name == 'cutadapt':
                        options = [
                            "- 'AGATCGGAAGAGC'         # Illumina \"TruSeq\" or \"ScriptSeq\" based libraries kits (default)",
                            "- 'CTGTCTCTTATACACATC'    # Illumina \"Nextera\" or \"TruSight\" based libraries kits (default)",
                            "- 'TGGAATTCTCGGGTGCCAAGG' # Illumina \"Small\" based libraries kits (default)",
                            "#- 'your_custom_adapter'   # Add your custom adapter"
                        ]
                    elif key == 'tmp_dir' and current_section_name == 'resources':
                        options = [
                            "## -'$TMPDIR'  # System variable $TMPDIR (default)",
                            "## -'.'        # Local (i.e. GeVarLi directory)",
                            "## -'/scratch' # HPC (set it to match your HPC usage)",
                            "## -''         # Custom (set your own)"
                        ]

                    app_state.config_fields.append((key, key, field_type, options)) # (display_name, key, type, options)

        # Build UI for each field
        for i, (display_name, key, field_type, options) in enumerate(app_state.config_fields):
            if i == app_state.config_field_index:
                label_style = "selected-item"
            else:
                label_style = "default"

            # Determine the path for the value based on if it's a nested key within 'primers'
            if len(app_state.current_config_path) > 1 and app_state.current_config_path[0] == 'primers' and key in ['path', 'scheme']:
                field_path = app_state.current_config_path + [key]
            else:
                field_path = app_state.current_config_path + [key]

            config_content_widgets.append(
                HSplit([
                    Label(text=f"{display_name}:", style=label_style),
                    get_field_input_ui(key, app_state.get_config_value(field_path), field_type, options)
                ])
            )
            config_content_widgets.append(Window(height=1, char=' ')) # Spacer

    # Navigation buttons
    def go_back():
        app_state.current_screen = 'main_menu'
        app_state.config_section_index = 0
        app.invalidate()

    def save_and_exit():
        app_state.save_config()
        app_state.current_screen = 'main_menu'
        app.invalidate()

    back_button = Button(" Back ", handler=go_back)
    save_button = Button(" Save & Exit ", handler=save_and_exit)

    config_section_selector = RadioList(
        values=[(sec[0], sec[0]) for sec in sections],
        default_value=current_section_name
    )

    def _on_section_change(radio_list):
        for i, (name, _) in enumerate(sections):
            if name == radio_list.current_value:
                app_state.config_section_index = i
                app_state.config_field_index = 0 # Reset field index when section changes
                app_state.current_config_path = [name] # Update current config path
                break
        app.invalidate()

    config_section_selector.on_change = _on_section_change

    return HSplit([
        Window(content=FormattedTextControl(GEVARLI_ASCII_LOGO, style="header")),
        Window(height=1, char=' '), # Spacer
        Frame(
            HSplit([
                Label(f"[title]Configuring: {current_section_name}[/title]"),
                Window(height=1, char=' '),
                Label("Select Section:", style="label"),
                config_section_selector,
                Window(height=1, char=' '),
                Label("Edit Fields:", style="label"),
                HSplit(config_content_widgets) # Dynamic content for fields
            ]),
            title="[title]GeVarLi Configuration[/title]"
        ),
        Window(height=1, char=' '), # Spacer
        VSplit([
            Window(content=back_button, align="left"),
            Window(content=save_button, align="right")
        ], height=D(max=1)),
        Label(text="Use [Up/Down] to navigate, [Tab] to switch focus.", style="label")
    ], width=D(preferred=100, max=100, min=100), height=D(preferred=30))

def get_run_analysis_ui(app_state, app):
    """Generates the run analysis UI (placeholder)."""
    def start_analysis():
        app_state.message = "Simulating analysis run... (This would execute Snakemake)"
        app_state.show_message_box = True
        # Here you would integrate the call to the Snakemake workflow
        # using subprocess.run or similar.
        # Example (conceptual):
        # import subprocess
        # try:
        #     subprocess.run(['bash', 'Run_GeVarLi.sh'], check=True)
        #     app_state.message = "Analysis completed successfully!"
        # except subprocess.CalledProcessError as e:
        #     app_state.message = f"Analysis failed: {e}"
        # app_state.show_message_box = True

    def go_back():
        app_state.current_screen = 'main_menu'
        app.invalidate()

    start_button = Button(" Start Analysis ", handler=start_analysis)
    back_button = Button(" Back ", handler=go_back)

    return HSplit([
        Window(content=FormattedTextControl(GEVARLI_ASCII_LOGO, style="header")),
        Window(height=1, char=' '), # Spacer
        Frame(
            HSplit([
                Label("[title]Run GeVarLi Analysis[/title]"),
                Window(height=1, char=' '),
                Label("This section allows you to start the GeVarLi analysis workflow.", style="message"),
                Label("The current configuration (from config.yaml) will be used.", style="message"),
                Window(height=1, char=' '),
                Label("Press 'Start Analysis' to begin.", style="message"),
            ]),
            title="[title]Run Analysis[/title]"
        ),
        Window(height=1, char=' '), # Spacer
        VSplit([
            Window(content=back_button, align="left"),
            Window(content=start_button, align="right")
        ], height=D(max=1))
    ], width=D(preferred=80, max=80, min=80), height=D(preferred=20))

def get_view_status_ui(app_state, app):
    """Generates the view status UI."""
    def go_back():
        app_state.current_screen = 'main_menu'
        app.invalidate()

    back_button = Button(" Back ", handler=go_back)

    # Use Rich to render config data as a table/text
    console = Console(record=True, force_terminal=True, width=80) # Record output to get plain text

    # Capture Rich's output
    with console:
        console.print(Panel(
            Text("GeVarLi Current Configuration", justify="center", style="bold green"),
            title="[bold yellow]Configuration Details[/bold yellow]",
            subtitle="[dim white]Loaded from config.yaml[/dim white]",
            border_style="blue"
        ))

        # Flatten config_data for display in a table
        flat_config = []
        def flatten_dict(d, parent_key=''):
            for k, v in d.items():
                new_key = f"{parent_key}.{k}" if parent_key else k
                if isinstance(v, dict):
                    flatten_dict(v, new_key)
                elif isinstance(v, list):
                    flat_config.append((new_key, ", ".join(map(str, v))))
                else:
                    flat_config.append((new_key, str(v)))

        flatten_dict(app_state.config_data)

        config_table = Table(show_header=True, header_style="bold magenta", border_style="dim")
        config_table.add_column("Setting")
        config_table.add_column("Value")

        for key, value in flat_config:
            config_table.add_row(key, value)

        console.print(config_table)

    status_text = console.export_text()

    return HSplit([
        Window(content=FormattedTextControl(GEVARLI_ASCII_LOGO, style="header")),
        Window(height=1, char=' '), # Spacer
        Frame(
            Window(content=FormattedTextControl(status_text), wrap_lines=True, style="text-area"),
            title="[title]GeVarLi Status & Configuration[/title]"
        ),
        Window(height=1, char=' '), # Spacer
        Window(content=back_button, align="center")
    ], width=D(preferred=100, max=100, min=100), height=D(preferred=30))


# --- Main Application Logic ---
def create_application():
    app_state = AppState()
    app_state.menu_index = 0 # Initialize menu index

    # Key bindings for navigation
    kb = KeyBindings()

    @kb.add('c-c') # Ctrl+C to exit
    def _(event):
        event.app.exit()

    @kb.add('up')
    def _(event):
        if app_state.current_screen == 'main_menu':
            app_state.menu_index = (app_state.menu_index - 1) % len(get_main_menu_items())
        elif app_state.current_screen == 'config_menu':
            # Handle navigation within config fields or sections
            if event.app.layout.current_window.content.__class__.__name__ == 'RadioList':
                # Navigate RadioList
                event.app.layout.current_window.content.control.up()
            else:
                # Navigate between other fields if not in RadioList
                if app_state.config_fields:
                    app_state.config_field_index = (app_state.config_field_index - 1) % len(app_state.config_fields)
        event.app.invalidate()

    @kb.add('down')
    def _(event):
        if app_state.current_screen == 'main_menu':
            app_state.menu_index = (app_state.menu_index + 1) % len(get_main_menu_items())
        elif app_state.current_screen == 'config_menu':
            # Handle navigation within config fields or sections
            if event.app.layout.current_window.content.__class__.__name__ == 'RadioList':
                # Navigate RadioList
                event.app.layout.current_window.content.control.down()
            else:
                # Navigate between other fields if not in RadioList
                if app_state.config_fields:
                    app_state.config_field_index = (app_state.config_field_index + 1) % len(app_state.config_fields)
        event.app.invalidate()

    @kb.add('enter')
    def _(event):
        if app_state.current_screen == 'main_menu':
            selected_action = get_main_menu_items()[app_state.menu_index][1]
            if selected_action == 'config_menu':
                app_state.current_screen = 'config_menu'
                app_state.config_section_index = 0 # Reset to first section
                app_state.load_config() # Reload config to ensure latest is shown
            elif selected_action == 'run_analysis':
                app_state.current_screen = 'run_analysis'
            elif selected_action == 'view_status':
                app_state.current_screen = 'view_status'
                app_state.load_config() # Reload config to ensure latest is shown
            elif selected_action == 'exit_app':
                event.app.exit()
        # For config menu, 'enter' can trigger specific actions on current field (e.g., open a sub-dialog)
        # For now, it just invalidates, which might be useful if a field changes interaction type.
        event.app.invalidate()


    @kb.add('tab')
    def _(event):
        # Cycle focus between different widgets (buttons, text areas, radio lists)
        event.app.layout.focus_next()
        event.app.invalidate()

    # Main layout container
    root_container = HSplit([
        ConditionalContainer(
            content=get_main_menu_ui(app_state, None),
            filter=(lambda: app_state.current_screen == 'main_menu')
        ),
        ConditionalContainer(
            content=get_config_menu_ui(app_state, None),
            filter=(lambda: app_state.current_screen == 'config_menu')
        ),
        ConditionalContainer(
            content=get_run_analysis_ui(app_state, None),
            filter=(lambda: app_state.current_screen == 'run_analysis')
        ),
         ConditionalContainer(
            content=get_view_status_ui(app_state, None),
            filter=(lambda: app_state.current_screen == 'view_status')
        ),
        ConditionalContainer(
            content=MessageBox(app_state),
            filter=(lambda: app_state.show_message_box)
        )
    ])

    app = Application(
        layout=Layout(root_container, focused_element=root_container.children[0]),
        key_bindings=kb,
        style=style,
        full_screen=True
    )

    return app, app_state

def main():
    app, app_state = create_application()
    app.run()

if __name__ == '__main__':
    main()
