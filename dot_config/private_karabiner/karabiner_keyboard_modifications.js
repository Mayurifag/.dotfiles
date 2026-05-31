var REMOTE_APPLICATIONS = [
  "^com\\.microsoft\\.rdc$",
  "^com\\.microsoft\\.rdc\\.mac$",
  "^com\\.microsoft\\.rdc\\.macos$",
  "^com\\.microsoft\\.rdc\\.osx\\.beta$",
  "^net\\.sf\\.cord$",
  "^com\\.thinomenon\\.RemoteDesktopConnection$",
  "^com\\.itap-mobile\\.qmote$",
  "^com\\.nulana\\.remotixmac$",
  "^com\\.p5sys\\.jump\\.mac\\.viewer$",
  "^com\\.p5sys\\.jump\\.mac\\.viewer\\.web$",
  "^com\\.teamviewer\\.TeamViewer$",
  "^com\\.2X\\.Client\\.Mac$",
  "^com\\.vmware\\.",
  "^com\\.parallels\\.",
  "^org\\.virtualbox\\.app\\.VirtualBoxVM$",
  "^com\\.citrix\\.XenAppViewer$",
];

var ITERM_APPLICATIONS = ["^com\\.googlecode\\.iterm2$"];

var ANY = ["any"];
var FN = ["fn"];
var CTRL = ["control"];
var CTRL_SHIFT = ["control", "shift"];
var COMMAND = ["command"];
var COMMAND_OPTION = ["command", "option"];
var LEFT_COMMAND = ["left_command"];
var LEFT_COMMAND_SHIFT = ["left_command", "left_shift"];

var UNLESS_REMOTE_APPLICATIONS = [
  {
    type: "frontmost_application_unless",
    bundle_identifiers: REMOTE_APPLICATIONS,
  },
];

var UNLESS_REMOTE_OR_ITERM_APPLICATIONS = UNLESS_REMOTE_APPLICATIONS.concat([
  {
    type: "frontmost_application_unless",
    bundle_identifiers: ITERM_APPLICATIONS,
  },
]);

var EXTERNAL_KEYBOARD = [
  {
    type: "device_unless",
    identifiers: [{ is_built_in_keyboard: true }],
  },
];

function trigger(keyCode, options) {
  var event = { key_code: keyCode };
  var modifiers = options && options.modifiers;
  var optional = options && options.optional;

  if (modifiers || optional) {
    event.modifiers = {};
  }
  if (modifiers) {
    event.modifiers.mandatory = modifiers;
  }
  if (optional) {
    event.modifiers.optional = optional;
  }

  return event;
}

function press(keyCode, options) {
  var event = { key_code: keyCode };

  if (options && options.modifiers) {
    event.modifiers = options.modifiers;
  }
  if (options && options.repeat !== undefined) {
    event.repeat = options.repeat;
  }

  return event;
}

function shell(command) {
  return { shell_command: command };
}

function rule(spec) {
  var manipulator = {
    type: "basic",
    description: spec.description,
    from: spec.from,
  };

  if (spec.to) {
    manipulator.to = [spec.to];
  }
  if (spec.conditions) {
    manipulator.conditions = spec.conditions;
  }
  if (spec.toIfHeldDown) {
    manipulator.to_if_held_down = [spec.toIfHeldDown];
  }

  return manipulator;
}

var RULES = [
  rule({
    description: "External keyboard: left Option -> left Command",
    from: trigger("left_option", { optional: ANY }),
    to: press("left_command"),
    conditions: EXTERNAL_KEYBOARD,
  }),
  rule({
    description: "External keyboard: left Command -> left Option",
    from: trigger("left_command", { optional: ANY }),
    to: press("left_option"),
    conditions: EXTERNAL_KEYBOARD,
  }),
  rule({
    description: "Fn + Backspace -> Forward Delete",
    from: trigger("delete_or_backspace", { modifiers: FN }),
    to: press("delete_forward"),
  }),
  rule({
    description: "Command + Esc -> Command + `",
    from: trigger("escape", { modifiers: LEFT_COMMAND }),
    to: press("grave_accent_and_tilde", { modifiers: LEFT_COMMAND }),
  }),
  rule({
    description: "Command + E -> Finder",
    from: trigger("e", { modifiers: COMMAND }),
    to: shell("open -a 'Finder.app'"),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+C -> Command+C",
    from: trigger("c", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("c", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+V -> Command+V",
    from: trigger("v", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("v", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+F -> Command+Shift+F",
    from: trigger("f", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("f", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+X -> Command+Shift+X",
    from: trigger("x", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("x", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+Z -> Command+Shift+Z",
    from: trigger("z", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("z", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+A -> Command+Shift+A",
    from: trigger("a", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("a", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+W -> Command+Shift+W",
    from: trigger("w", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("w", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+T -> Command+Shift+T",
    from: trigger("t", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("t", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+1 -> Command+Shift+1",
    from: trigger("1", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("1", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+2 -> Command+Shift+2",
    from: trigger("2", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("2", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+3 -> Command+Shift+3",
    from: trigger("3", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("3", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+4 -> Command+Shift+4",
    from: trigger("4", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("4", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+5 -> Command+Shift+5",
    from: trigger("5", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("5", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+6 -> Command+Shift+6",
    from: trigger("6", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("6", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+7 -> Command+Shift+7",
    from: trigger("7", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("7", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+8 -> Command+Shift+8",
    from: trigger("8", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("8", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+9 -> Command+Shift+9",
    from: trigger("9", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("9", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Shift+Y -> Command+Shift+Z",
    from: trigger("y", { modifiers: CTRL_SHIFT, optional: ANY }),
    to: press("z", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+F -> Command+F",
    from: trigger("f", { modifiers: CTRL, optional: ANY }),
    to: press("f", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+C -> Command+C",
    from: trigger("c", { modifiers: CTRL, optional: ANY }),
    to: press("c", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_OR_ITERM_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+V -> Command+V",
    from: trigger("v", { modifiers: CTRL, optional: ANY }),
    to: press("v", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+X -> Command+X",
    from: trigger("x", { modifiers: CTRL, optional: ANY }),
    to: press("x", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Z -> Command+Z",
    from: trigger("z", { modifiers: CTRL, optional: ANY }),
    to: press("z", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+Y -> Command+Shift+Z",
    from: trigger("y", { modifiers: CTRL, optional: ANY }),
    to: press("z", { modifiers: LEFT_COMMAND_SHIFT }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+A -> Command+A",
    from: trigger("a", { modifiers: CTRL, optional: ANY }),
    to: press("a", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+W -> Command+W",
    from: trigger("w", { modifiers: CTRL, optional: ANY }),
    to: press("w", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+T -> Command+T",
    from: trigger("t", { modifiers: CTRL, optional: ANY }),
    to: press("t", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+1 -> Command+1",
    from: trigger("1", { modifiers: CTRL, optional: ANY }),
    to: press("1", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+2 -> Command+2",
    from: trigger("2", { modifiers: CTRL, optional: ANY }),
    to: press("2", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+3 -> Command+3",
    from: trigger("3", { modifiers: CTRL, optional: ANY }),
    to: press("3", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+4 -> Command+4",
    from: trigger("4", { modifiers: CTRL, optional: ANY }),
    to: press("4", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+5 -> Command+5",
    from: trigger("5", { modifiers: CTRL, optional: ANY }),
    to: press("5", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+6 -> Command+6",
    from: trigger("6", { modifiers: CTRL, optional: ANY }),
    to: press("6", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+7 -> Command+7",
    from: trigger("7", { modifiers: CTRL, optional: ANY }),
    to: press("7", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+8 -> Command+8",
    from: trigger("8", { modifiers: CTRL, optional: ANY }),
    to: press("8", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "Ctrl+9 -> Command+9",
    from: trigger("9", { modifiers: CTRL, optional: ANY }),
    to: press("9", { modifiers: LEFT_COMMAND }),
    conditions: UNLESS_REMOTE_APPLICATIONS,
  }),
  rule({
    description: "CapsLock -> Command+Space",
    from: trigger("caps_lock"),
    to: press("spacebar", { modifiers: LEFT_COMMAND, repeat: false }),
    toIfHeldDown: press("spacebar", {
      modifiers: LEFT_COMMAND,
      repeat: true,
    }),
  }),
  rule({
    description: "Disable Command+H",
    from: trigger("h", { modifiers: COMMAND }),
  }),
  rule({
    description: "Disable Command+Option+H",
    from: trigger("h", { modifiers: COMMAND_OPTION, optional: ANY }),
  }),
  rule({
    description: "Disable Command+Option+M",
    from: trigger("m", { modifiers: COMMAND_OPTION, optional: ANY }),
  }),
];

({
  description: "Keyboard modifications",
  manipulators: RULES,
});
