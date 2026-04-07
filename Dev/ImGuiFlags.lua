local _ENV = setmetatable({}, {__index=_G,__newindex=rawset})


local s = 0
for k, v in pairs(imgui) do
	s = s + 1
end
if s > 150 then
	BackendFlags = {
		HasGamepad = {
			value = 1,
			tooltip = "Backend Platform supports gamepad and currently has one connected.",
			active = false,
		},
		HasMouseCursors = {
			value = 2,
			tooltip = "Backend Platform supports honoring GetMouseCursor() value to change the OS cursor shape.",
			active = false,
		},
		HasParentViewport = {
			value = 8192,
			tooltip = "Backend Platform supports honoring viewport->ParentViewport/ParentViewportId value, by",
			active = false,
		},
		HasSetMousePos = {
			value = 4,
			tooltip = "Backend Platform supports io.WantSetMousePos requests to reposition the OS mouse position",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		PlatformHasViewports = {
			value = 2048,
			tooltip = "Backend Platform supports multiple viewports.",
			active = false,
		},
		RendererHasViewports = {
			value = 1024,
			tooltip = "Backend Renderer supports multiple viewports.",
			active = false,
		},
		RendererHasVtxOffset = {
			value = 8,
			tooltip = "Backend Renderer supports ImDrawCmd::VtxOffset. This enables output of large meshes",
			active = false,
		},
	}
	ButtonFlags = {
		EnableNav = {
			value = 8,
			tooltip = "InvisibleButton(): do not disable navigation/tabbing. Otherwise disabled by default.",
			active = false,
		},
		MouseButtonLeft = {
			value = 1,
			tooltip = "React on left mouse button (default)",
			active = false,
		},
		MouseButtonMiddle = {
			value = 4,
			tooltip = "React on center mouse button",
			active = false,
		},
		MouseButtonRight = {
			value = 2,
			tooltip = "React on right mouse button",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
	}
	ChildFlags = {
		AlwaysAutoResize = {
			value = 64,
			tooltip = "Combined with AutoResizeX/AutoResizeY. Always measure size even when child is hidden,",
			active = false,
		},
		AlwaysUseWindowPadding = {
			value = 2,
			tooltip = "Pad with style.WindowPadding even if no border are drawn (no padding by default for",
			active = false,
		},
		AutoResizeX = {
			value = 16,
			tooltip = "Enable auto-resizing width. Read \"IMPORTANT: Size measurement\" details above.",
			active = false,
		},
		AutoResizeY = {
			value = 32,
			tooltip = "Enable auto-resizing height. Read \"IMPORTANT: Size measurement\" details above.",
			active = false,
		},
		FrameStyle = {
			value = 128,
			tooltip = "Style the child window like a framed item: use FrameBg, FrameRounding, FrameBorderSize,",
			active = false,
		},
		NavFlattened = {
			value = 256,
			tooltip = "[BETA] Share focus scope, allow keyboard/gamepad navigation to cross over parent border to",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		ResizeX = {
			value = 4,
			tooltip = "Allow resize from right border (layout direction). Enable .ini saving (unless",
			active = false,
		},
		ResizeY = {
			value = 8,
			tooltip = "Allow resize from bottom border (layout direction). \"",
			active = false,
		},
	}
	ColorEditFlags = {
		AlphaBar = {
			value = 65536,
			tooltip = "",
			active = false,
		},
		DisplayHex = {
			value = 4194304,
			tooltip = "[Display]",
			active = false,
		},
		DisplayHSV = {
			value = 2097152,
			tooltip = "[Display]",
			active = false,
		},
		DisplayRGB = {
			value = 1048576,
			tooltip = "[Display]",
			active = false,
		},
		Float = {
			value = 16777216,
			tooltip = "[DataType]",
			active = false,
		},
		HDR = {
			value = 524288,
			tooltip = "",
			active = false,
		},
		InputHSV = {
			value = 268435456,
			tooltip = "[Input]",
			active = false,
		},
		InputRGB = {
			value = 134217728,
			tooltip = "[Input]",
			active = false,
		},
		NoAlpha = {
			value = 2,
			tooltip = "",
			active = false,
		},
		NoBorder = {
			value = 1024,
			tooltip = "",
			active = false,
		},
		NoInputs = {
			value = 32,
			tooltip = "",
			active = false,
		},
		NoLabel = {
			value = 128,
			tooltip = "",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoPicker = {
			value = 4,
			tooltip = "",
			active = false,
		},
		NoSidePreview = {
			value = 256,
			tooltip = "",
			active = false,
		},
		PickerHueBar = {
			value = 33554432,
			tooltip = "[Picker]",
			active = false,
		},
		PickerHueWheel = {
			value = 67108864,
			tooltip = "[Picker]",
			active = false,
		},
		Uint8 = {
			value = 8388608,
			tooltip = "[DataType]",
			active = false,
		},
	}
	ComboFlags = {
		HeightLarge = {
			value = 8,
			tooltip = "Max ~20 items visible",
			active = false,
		},
		HeightLargest = {
			value = 16,
			tooltip = "As many fitting items as possible",
			active = false,
		},
		HeightRegular = {
			value = 4,
			tooltip = "Max ~8 items visible (default)",
			active = false,
		},
		HeightSmall = {
			value = 2,
			tooltip = "Max ~4 items visible. Tip: If you want your combo popup to be a specific size you can use",
			active = false,
		},
		NoArrowButton = {
			value = 32,
			tooltip = "Display on the preview box without the square arrow button",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoPreview = {
			value = 64,
			tooltip = "Display only a square arrow button",
			active = false,
		},
		PopupAlignLeft = {
			value = 1,
			tooltip = "Align the popup toward the left by default",
			active = false,
		},
		WidthFitPreview = {
			value = 128,
			tooltip = "Width dynamically calculated from preview contents",
			active = false,
		},
	}
	ConfigFlags = {
		DockingEnable = {
			value = 128,
			tooltip = "Docking enable flags.",
			active = false,
		},
		DpiEnableScaleFonts = {
			value = 16384,
			tooltip = "[moved/renamed in 1.92.0] -> use bool io.ConfigDpiScaleFonts",
			active = false,
		},
		DpiEnableScaleViewports = {
			value = 32768,
			tooltip = "[moved/renamed in 1.92.0] -> use bool io.ConfigDpiScaleViewports",
			active = false,
		},
		IsSRGB = {
			value = 1048576,
			tooltip = "Application is SRGB-aware.",
			active = false,
		},
		IsTouchScreen = {
			value = 2097152,
			tooltip = "Application is using a touch screen instead of a mouse.",
			active = false,
		},
		NavEnableSetMousePos = {
			value = 4,
			tooltip = "[moved/renamed in 1.91.4] -> use bool io.ConfigNavMoveSetMousePos",
			active = false,
		},
		NavNoCaptureKeyboard = {
			value = 8,
			tooltip = "[moved/renamed in 1.91.4] -> use bool io.ConfigNavCaptureKeyboard",
			active = false,
		},
		NoKeyboard = {
			value = 64,
			tooltip = "Instruct dear imgui to disable keyboard inputs and interactions. This is done by ignoring",
			active = false,
		},
		NoMouse = {
			value = 16,
			tooltip = "Instruct dear imgui to disable mouse inputs and interactions.",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		ViewportsEnable = {
			value = 1024,
			tooltip = "Viewport enable flags (require both ImGuiBackendFlags_PlatformHasViewports +",
			active = false,
		},
	}
	DockNodeFlags = {
		AutoHideTabBar = {
			value = 64,
			tooltip = "",
			active = false,
		},
		NoDockingInCentralNode = {
			value = nil,
			tooltip = "Renamed in 1.90",
			active = false,
		},
		NoDockingOverCentralNode = {
			value = 1,
			tooltip = "",
			active = false,
		},
		NoDockingSplit = {
			value = 16,
			tooltip = "",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoSplit = {
			value = nil,
			tooltip = "Renamed in 1.90",
			active = false,
		},
		NoUndocking = {
			value = 128,
			tooltip = "",
			active = false,
		},
	}
	DragDropFlags = {
		AcceptBeforeDelivery = {
			value = 1,
			tooltip = "",
			active = false,
		},
		AcceptNoDrawDefaultRect = {
			value = 2048,
			tooltip = "Do not draw the default highlight rectangle when hovering over target.",
			active = false,
		},
		AcceptNoPreviewTooltip = {
			value = 1,
			tooltip = "",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		PayloadAutoExpire = {
			value = 32,
			tooltip = "Automatically expire the payload if the source cease to be submitted (otherwise",
			active = false,
		},
		PayloadNoCrossProcess = {
			value = 128,
			tooltip = "Hint to specify that the payload may not be copied outside current process.",
			active = false,
		},
		SourceAutoExpirePayload = {
			value = nil,
			tooltip = "Renamed in 1.90.9",
			active = false,
		},
		SourceExtern = {
			value = 16,
			tooltip = "External source (from outside of dear imgui), won't attempt to read current item/window",
			active = false,
		},
		SourceNoHoldToOpenOthers = {
			value = 4,
			tooltip = "Disable the behavior that allows to open tree nodes and collapsing header by",
			active = false,
		},
	}
	FocusedFlags = {
		AnyWindow = {
			value = 4,
			tooltip = "Return true if any window is focused. Important: If you are trying to tell how to dispatch your",
			active = false,
		},
		ChildWindows = {
			value = 1,
			tooltip = "Return true if any children of the window is focused",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoPopupHierarchy = {
			value = 8,
			tooltip = "Do not consider popup hierarchy (do not treat popup emitter as parent of popup) (when",
			active = false,
		},
		RootAndChildWindows = {
			value = "ImGuiFlags.FocusedFlags.RootWindow.value + ImGuiFlags.FocusedFlags.ChildWindows.value",
			tooltip = "",
			active = false,
		},
		RootWindow = {
			value = 2,
			tooltip = "Test from root window (top most parent of the current hierarchy)",
			active = false,
		},
	}
	HoveredFlags = {
		AllowWhenBlockedByPopup = {
			value = 1,
			tooltip = "",
			active = false,
		},
		AllowWhenBlockedByActiveItem = {
			value = 128,
			tooltip = "IsItemHovered() only: Return true even if the item is disabled",
			active = false,
		},
		AllowWhenOverlappedByItem = {
			value = 256,
			tooltip = "IsItemHovered() only: Return true even if the item is disabled",
			active = false,
		},
		AllowWhenOverlappedByWindow = {
			value = 512,
			tooltip = "IsItemHovered() only: Return true even if the item is disabled",
			active = false,
		},
		AllowWhenOverlapped = {
			value = 768,
			tooltip = "IsItemHovered() only: Return true even if the item is disabled",
			active = false,
		},
		RectOnly = {
			value = 928,
			tooltip = "IsItemHovered() only: Return true even if the item is disabled",
			active = false,
		},
		AllowWhenDisabled = {
			value = 1024,
			tooltip = "IsItemHovered() only: Return true even if the item is disabled",
			active = false,
		},
		AnyWindow = {
			value = 4,
			tooltip = "IsWindowHovered() only: Return true if any window is hovered",
			active = false,
		},
		ChildWindows = {
			value = 1,
			tooltip = "IsWindowHovered() only: Return true if any children of the window is hovered",
			active = false,
		},
		DockHierarchy = {
			value = 16,
			tooltip = "IsWindowHovered() only: Consider docking hierarchy (treat dockspace host as parent of",
			active = false,
		},
		ForTooltip = {
			value = 4096,
			tooltip = "Shortcut for standard flags when using IsItemHovered() + SetTooltip() sequence.",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "Return true if directly over the item/window, not obstructed by another window, not obstructed by an",
			active = false,
		},
		NoPopupHierarchy = {
			value = 8,
			tooltip = "IsWindowHovered() only: Do not consider popup hierarchy (do not treat popup emitter as",
			active = false,
		},
		NoSharedDelay = {
			value = 131072,
			tooltip = "IsItemHovered() only: Disable shared delay system where moving from one item to the next",
			active = false,
		},
		RootWindow = {
			value = 2,
			tooltip = "IsWindowHovered() only: Test from root window (top most parent of the current hierarchy)",
			active = false,
		},
		NoNavOverride= {
			value = 2048,
			tooltip = "IsWindowHovered() only: Test from root window (top most parent of the current hierarchy)",
			active = false,
		}
	}
	InputFlags = {
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		Repeat = {
			value = 1,
			tooltip = "Enable repeat. Return true on successive repeats. Default for legacy IsKeyPressed(). NOT Default for",
			active = false,
		},
		RouteActive = {
			value = 1024,
			tooltip = "Route to active item only.",
			active = false,
		},
		RouteAlways = {
			value = 8192,
			tooltip = "Do not register route, poll keys directly.",
			active = false,
		},
		RouteFocused = {
			value = 2048,
			tooltip = "Route to windows in the focus stack (DEFAULT). Deep-most focused window takes inputs. Active",
			active = false,
		},
		RouteGlobal = {
			value = 4096,
			tooltip = "Global route (unless a focused window or active item registered the route).",
			active = false,
		},
		RouteUnlessBgFocused = {
			value = 65536,
			tooltip = "Option: global route: will not be applied if underlying background/void is focused",
			active = false,
		},
		Tooltip = {
			value = 262144,
			tooltip = "Automatically display a tooltip when hovering item [BETA] Unsure of right api (opt-in/opt-out)",
			active = false,
		},
	}
	InputTextFlags = {
		AllowTabInput = {
			value = 32,
			tooltip = "Pressing TAB input a '\\t' character into the text field",
			active = false,
		},
		AlwaysOverwrite = {
			value = 2048,
			tooltip = "Overwrite mode",
			active = false,
		},
		AutoSelectAll = {
			value = 4096,
			tooltip = "Select entire text when first taking mouse focus",
			active = false,
		},
		CallbackAlways = {
			value = 1048576,
			tooltip = "Callback on each iteration. User code may query cursor position, modify text buffer.",
			active = false,
		},
		CallbackCharFilter = {
			value = 2097152,
			tooltip = "Callback on character inputs to replace or discard them. Modify 'EventChar' to",
			active = false,
		},
		CallbackCompletion = {
			value = 262144,
			tooltip = "Callback on pressing TAB (for completion handling)",
			active = false,
		},
		CallbackHistory = {
			value = 524288,
			tooltip = "Callback on pressing Up/Down arrows (for history handling)",
			active = false,
		},
		CharsDecimal = {
			value = 1,
			tooltip = "Allow 0123456789.+-*/",
			active = false,
		},
		CharsHexadecimal = {
			value = 2,
			tooltip = "Allow 0123456789ABCDEFabcdef",
			active = false,
		},
		CharsNoBlank = {
			value = 16,
			tooltip = "Filter out spaces, tabs",
			active = false,
		},
		CharsScientific = {
			value = 4,
			tooltip = "Allow 0123456789.+-*/eE (Scientific notation input)",
			active = false,
		},
		CharsUppercase = {
			value = 8,
			tooltip = "Turn a..z into A..Z",
			active = false,
		},
		CtrlEnterForNewLine = {
			value = 256,
			tooltip = "In multi-line mode, validate with Enter, add new line with Ctrl+Enter (default is",
			active = false,
		},
		DisplayEmptyRefVal = {
			value = 16384,
			tooltip = "InputFloat(), InputInt(), InputScalar() etc. only: when value is zero, do not",
			active = false,
		},
		EnterReturnsTrue = {
			value = 64,
			tooltip = "Return 'true' when Enter is pressed (as opposed to every time the value was modified).",
			active = false,
		},
		NoHorizontalScroll = {
			value = 32768,
			tooltip = "Disable following the cursor horizontally",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoUndoRedo = {
			value = 65536,
			tooltip = "Disable undo/redo. Note that input text owns the text data while active, if you want to",
			active = false,
		},
		ParseEmptyRefVal = {
			value = 8192,
			tooltip = "InputFloat(), InputInt(), InputScalar() etc. only: parse empty string as zero value.",
			active = false,
		},
		Password = {
			value = 1024,
			tooltip = "Password mode, display all characters as '*', disable copy",
			active = false,
		},
		ReadOnly = {
			value = 512,
			tooltip = "Read-only mode",
			active = false,
		},
		WordWrap = {
			value = 16777216,
			tooltip = "InputTextMultiline(): word-wrap lines that are too long.",
			active = false,
		},
	}
	ItemFlags = {
		AutoClosePopups = {
			value = 16,
			tooltip = "true",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "(Default)",
			active = false,
		},
		NoTabStop = {
			value = 1,
			tooltip = "false",
			active = false,
		},
	}
	PopupFlags = {
		AnyPopupId = {
			value = 1024,
			tooltip = "For IsPopupOpen(): ignore the ImGuiID parameter and test for any popup.",
			active = false,
		},
		MouseButtonDefault_ = {
			value = 1,
			tooltip = "",
			active = false,
		},
		MouseButtonMask_ = {
			value = 31,
			tooltip = "",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoReopen = {
			value = 32,
			tooltip = "For OpenPopup*(), BeginPopupContext*(): don't reopen same popup if already open (won't reposition,",
			active = false,
		},
	}
	SelectableFlags = {
		AllowDoubleClick = {
			value = 4,
			tooltip = "Generate press events on double clicks too",
			active = false,
		},
		AllowOverlap = {
			value = 16,
			tooltip = "(WIP) Hit testing to allow subsequent widgets to overlap this one",
			active = false,
		},
		Disabled = {
			value = 8,
			tooltip = "Cannot be selected, display grayed out text",
			active = false,
		},
		Highlight = {
			value = 32,
			tooltip = "Make the item be displayed as if it is hovered",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
	}
	SliderFlags = {
		ClampZeroRange = {
			value = 1024,
			tooltip = "Clamp even if min==max==0.0f. Otherwise due to legacy reason DragXXX functions don't clamp",
			active = false,
		},
		InvalidMask_ = {
			value = 1879048207,
			tooltip = "[Internal] We treat using those bits as being potentially a 'float power' argument from",
			active = false,
		},
		NoInput = {
			value = 128,
			tooltip = "Disable Ctrl+Click or Enter key allowing to input text directly into the widget.",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoRoundToFormat = {
			value = 64,
			tooltip = "Disable rounding underlying value to match precision of the display format string (e.g.",
			active = false,
		},
	}
	TabBarFlags = {
		AutoSelectNewTabs = {
			value = 2,
			tooltip = "Automatically select new tabs when they appear",
			active = false,
		},
		DrawSelectedOverline = {
			value = 64,
			tooltip = "Draw selected overline markers over selected tab",
			active = false,
		},
		FittingPolicyScroll = {
			value = 512,
			tooltip = "Enable scrolling buttons when tabs don't fit",
			active = false,
		},
		FittingPolicyShrink = {
			value = 256,
			tooltip = "Shrink down tabs when they don't fit",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoTooltip = {
			value = 32,
			tooltip = "Disable tooltips when hovering a tab",
			active = false,
		},
		Reorderable = {
			value = 1,
			tooltip = "Allow manually dragging tabs to re-order them + New tabs are appended at the end of list",
			active = false,
		},
		TabListPopupButton = {
			value = 4,
			tooltip = "Disable buttons to open the tab list popup",
			active = false,
		},
	}
	TabItemFlags = {
		Leading = {
			value = 64,
			tooltip = "Enforce the tab position to the left of the tab bar (after the tab list popup button)",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoPushId = {
			value = 8,
			tooltip = "Don't call PushID()/PopID() on BeginTabItem()/EndTabItem()",
			active = false,
		},
		NoReorder = {
			value = 32,
			tooltip = "Disable reordering this tab or having another tab cross over this tab",
			active = false,
		},
		NoTooltip = {
			value = 16,
			tooltip = "Disable tooltip for the given tab",
			active = false,
		},
		SetSelected = {
			value = 2,
			tooltip = "Trigger flag to programmatically make the tab selected when calling BeginTabItem()",
			active = false,
		},
		Trailing = {
			value = 128,
			tooltip = "Enforce the tab position to the right of the tab bar (before the scrolling buttons)",
			active = false,
		},
		UnsavedDocument = {
			value = 1,
			tooltip = "Display a dot next to the title + set ImGuiTabItemFlags_NoAssumedClosure.",
			active = false,
		},
	}
	TableColumnFlags = {
		DefaultHide = {
			value = 2,
			tooltip = "Default as a hidden/disabled column.",
			active = false,
		},
		DefaultSort = {
			value = 4,
			tooltip = "Default as a sorting column.",
			active = false,
		},
		Disabled = {
			value = 1,
			tooltip = "Overriding/master disable flag: hide column, won't show in context menu (unlike calling",
			active = false,
		},
		IndentDisable = {
			value = 131072,
			tooltip = "Ignore current Indent value when entering cell (default for columns > 0). Indentation",
			active = false,
		},
		IndentEnable = {
			value = 65536,
			tooltip = "Use current Indent value when entering cell (default for column 0).",
			active = false,
		},
		IndentMask_ = {
			value = "ImGuiFlags.TableColumnFlags.IndentEnable.value + ImGuiFlags.TableColumnFlags.IndentDisable.value",
			tooltip = "",
			active = false,
		},
		IsHovered = {
			value = 134217728,
			tooltip = "Status: is hovered by mouse",
			active = false,
		},
		IsSorted = {
			value = 67108864,
			tooltip = "Status: is currently part of the sort specs",
			active = false,
		},
		IsVisible = {
			value = 33554432,
			tooltip = "Status: is visible == is enabled AND not clipped by scrolling.",
			active = false,
		},
		NoClip = {
			value = 256,
			tooltip = "Disable clipping for this column (all NoClip columns will render in a same draw command).",
			active = false,
		},
		NoHeaderWidth = {
			value = 8192,
			tooltip = "Disable header text width contribution to automatic column width.",
			active = false,
		},
		NoHide = {
			value = 128,
			tooltip = "Disable ability to hide/disable this column.",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoResize = {
			value = 32,
			tooltip = "Disable manual resizing.",
			active = false,
		},
		NoSort = {
			value = 512,
			tooltip = "Disable ability to sort on this field (even if ImGuiTableFlags_Sortable is set on the table).",
			active = false,
		},
		NoSortAscending = {
			value = 1024,
			tooltip = "Disable ability to sort in the ascending direction.",
			active = false,
		},
		NoSortDescending = {
			value = 2048,
			tooltip = "Disable ability to sort in the descending direction.",
			active = false,
		},
		PreferSortDescending = {
			value = 32768,
			tooltip = "Make the initial sort direction Descending when first sorting on this column.",
			active = false,
		},
		WidthFixed = {
			value = 16,
			tooltip = "Column will not stretch. Preferable with horizontal scrolling enabled (default if table",
			active = false,
		},
		WidthStretch = {
			value = 8,
			tooltip = "Column will stretch. Preferable with horizontal scrolling disabled (default if table",
			active = false,
		},
	}
	TableFlags = {
		Borders = {
			value = "ImGuiFlags.TableFlags.BordersInner.value + ImGuiFlags.TableFlags.BordersOuter.value",
			tooltip = "Draw all borders.",
			active = false,
		},
		BordersH = {
			value = "ImGuiFlags.TableFlags.BordersInnerH.value + ImGuiFlags.TableFlags.BordersOuterH.value",
			tooltip = "Draw horizontal borders.",
			active = false,
		},
		BordersInner = {
			value = "ImGuiFlags.TableFlags.BordersInnerV.value + ImGuiFlags.TableFlags.BordersInnerH.value",
			tooltip = "Draw inner borders.",
			active = false,
		},
		BordersInnerH = {
			value = 128,
			tooltip = "Draw horizontal borders between rows.",
			active = false,
		},
		BordersInnerV = {
			value = 512,
			tooltip = "Draw vertical borders between columns.",
			active = false,
		},
		BordersOuterH = {
			value = 256,
			tooltip = "Draw horizontal borders at the top and bottom.",
			active = false,
		},
		BordersOuterV = {
			value = 1024,
			tooltip = "Draw vertical borders on the left and right sides.",
			active = false,
		},
		BordersV = {
			value = "ImGuiFlags.TableFlags.BordersInnerV.value + ImGuiFlags.TableFlags.BordersOuterV.value",
			tooltip = "Draw vertical borders.",
			active = false,
		},
		ContextMenuInBody = {
			value = 32,
			tooltip = "Right-click on columns body/contents will display table context menu. By default it is",
			active = false,
		},
		Hideable = {
			value = 4,
			tooltip = "Enable hiding/disabling columns in context menu.",
			active = false,
		},
		HighlightHoveredColumn = {
			value = 268435456,
			tooltip = "Highlight column headers when hovered (may evolve into a fuller highlight)",
			active = false,
		},
		NoClip = {
			value = 1048576,
			tooltip = "Disable clipping rectangle for every individual columns (reduce draw command count, items will be",
			active = false,
		},
		NoHostExtendX = {
			value = 65536,
			tooltip = "Make outer width auto-fit to columns, overriding outer_size.x value. Only available when",
			active = false,
		},
		NoKeepColumnsVisible = {
			value = 262144,
			tooltip = "Disable keeping column always minimally visible when ScrollX is off and table gets",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoPadInnerX = {
			value = 8388608,
			tooltip = "Disable inner padding between columns (double inner padding if BordersOuterV is on, single",
			active = false,
		},
		NoPadOuterX = {
			value = 4194304,
			tooltip = "Default if BordersOuterV is off. Disable outermost padding.",
			active = false,
		},
		NoSavedSettings = {
			value = 16,
			tooltip = "Disable persisting columns order, width and sort settings in the .ini file.",
			active = false,
		},
		PreciseWidths = {
			value = 524288,
			tooltip = "Disable distributing remainder width to stretched columns (width allocation on a 100-wide",
			active = false,
		},
		Resizable = {
			value = 1,
			tooltip = "Enable resizing columns.",
			active = false,
		},
		RowBg = {
			value = 64,
			tooltip = "Set each RowBg color with ImGuiCol_TableRowBg or ImGuiCol_TableRowBgAlt (equivalent of calling",
			active = false,
		},
		ScrollY = {
			value = 33554432,
			tooltip = "Enable vertical scrolling. Require 'outer_size' parameter of BeginTable() to specify the container",
			active = false,
		},
		SizingStretchSame = {
			value = 32768,
			tooltip = "Columns default to _WidthStretch with default weights all equal, unless overridden by",
			active = false,
		},
		Sortable = {
			value = 8,
			tooltip = "Enable sorting. Call TableGetSortSpecs() to obtain sort specs. Also see ImGuiTableFlags_SortMulti",
			active = false,
		},
		SortTristate = {
			value = 134217728,
			tooltip = "Allow no sorting, disable default sorting. TableGetSortSpecs() may return specs where",
			active = false,
		},
	}
	TableRowFlags = {
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
	}
	TreeNodeFlags = {
		AllowOverlap = {
			value = 4,
			tooltip = "Hit testing to allow subsequent widgets to overlap this one",
			active = false,
		},
		DefaultOpen = {
			value = 32,
			tooltip = "Default node to be open",
			active = false,
		},
		DrawLinesFull = {
			value = 524288,
			tooltip = "Horizontal lines to child nodes. Vertical line drawn down to TreePop() position: cover",
			active = false,
		},
		DrawLinesNone = {
			value = 262144,
			tooltip = "No lines drawn",
			active = false,
		},
		Framed = {
			value = 2,
			tooltip = "Draw frame with background (e.g. for CollapsingHeader)",
			active = false,
		},
		FramePadding = {
			value = 1024,
			tooltip = "Use FramePadding (even for an unframed text node) to vertically align text baseline to",
			active = false,
		},
		LabelSpanAllColumns = {
			value = 32768,
			tooltip = "Label will span all columns of its container table",
			active = false,
		},
		Leaf = {
			value = 256,
			tooltip = "No collapsing, no arrow (use as a convenience for leaf nodes).",
			active = false,
		},
		NavLeftJumpsBackHere = {
			value = nil,
			tooltip = "Renamed in 1.92.0",
			active = false,
		},
		NavLeftJumpsToParent = {
			value = 131072,
			tooltip = "Nav: left arrow moves back to parent. This is processed in TreePop() when there's",
			active = false,
		},
		NoAutoOpenOnLog = {
			value = 16,
			tooltip = "Don't automatically and temporarily open node when Logging is active (by default logging",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		OpenOnArrow = {
			value = 128,
			tooltip = "Open when clicking on the arrow part (default for multi-select unless any _OpenOnXXX",
			active = false,
		},
		OpenOnDoubleClick = {
			value = 64,
			tooltip = "Open on double-click instead of simple click (default for multi-select unless any",
			active = false,
		},
		Selected = {
			value = 1,
			tooltip = "Draw as selected",
			active = false,
		},
		SpanAvailWidth = {
			value = 2048,
			tooltip = "Extend hit box to the right-most edge, even if not framed. This is not the default in",
			active = false,
		},
		SpanFullWidth = {
			value = 4096,
			tooltip = "Extend hit box to the left-most and right-most edges (cover the indent area).",
			active = false,
		},
		SpanLabelWidth = {
			value = 8192,
			tooltip = "Narrow hit box + narrow hovering highlight, will only cover the label text.",
			active = false,
		},
		SpanTextWidth = {
			value = nil,
			tooltip = "Renamed in 1.90.7",
			active = false,
		},
	}
	WindowFlags = {
		AlwaysAutoResize = {
			value = 64,
			tooltip = "Resize every window to its content every frame",
			active = false,
		},
		AlwaysHorizontalScrollbar = {
			value = 32768,
			tooltip = "Always show horizontal scrollbar (even if ContentSize.x < Size.x)",
			active = false,
		},
		AlwaysVerticalScrollbar = {
			value = 16384,
			tooltip = "Always show vertical scrollbar (even if ContentSize.y < Size.y)",
			active = false,
		},
		ChildMenu = {
			value = 268435456,
			tooltip = "Don't use! For internal use by BeginMenu()",
			active = false,
		},
		ChildWindow = {
			value = 16777216,
			tooltip = "Don't use! For internal use by BeginChild()",
			active = false,
		},
		DockNodeHost = {
			value = 8388608,
			tooltip = "Don't use! For internal use by Begin()/NewFrame()",
			active = false,
		},
		MenuBar = {
			value = 1024,
			tooltip = "Has a menu-bar",
			active = false,
		},
		Modal = {
			value = 134217728,
			tooltip = "Don't use! For internal use by BeginPopupModal()",
			active = false,
		},
		NoBackground = {
			value = 128,
			tooltip = "No background",
			active = false,
		},
		NoBringToFrontOnFocus = {
			value = 8192,
			tooltip = "",
			active = false,
		},
		NoFocusOnAppearing  = {
			value = 4096,
			tooltip = "",
			active = false,
		},
		NoInputs = {
			value = 197120,
			tooltip = "",
			active = false,
		},
		NoCollapse = {
			value = 32,
			tooltip = "Disable user collapsing window by double-clicking on it. Also referred to as Window Menu Button",
			active = false,
		},
		NoDocking = {
			value = 524288,
			tooltip = "Disable docking of this window",
			active = false,
		},
		NoFocusOnAppearing = {
			value = 4096,
			tooltip = "Disable taking focus when transitioning from hidden to visible state",
			active = false,
		},
		NoMouseInputs = {
			value = 512,
			tooltip = "Disable catching mouse, hovering test with pass through.",
			active = false,
		},
		NoMove = {
			value = 4,
			tooltip = "Disable user moving the window",
			active = false,
		},
		NoDecoration = {
			value = 43,
			tooltip = "No focusing toward this window with keyboard/gamepad navigation (e.g. skipped by Ctrl+Tab)",
			active = false,
		},
		NoNav = {
			value = 196608,
			tooltip = "No focusing toward this window with keyboard/gamepad navigation (e.g. skipped by Ctrl+Tab)",
			active = false,
		},
		NoNavFocus = {
			value = 131072,
			tooltip = "No focusing toward this window with keyboard/gamepad navigation (e.g. skipped by Ctrl+Tab)",
			active = false,
		},
		NoNavInputs = {
			value = 65536,
			tooltip = "No keyboard/gamepad navigation within the window",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoResize = {
			value = 2,
			tooltip = "Disable user resizing with the lower-right grip",
			active = false,
		},
		NoSavedSettings = {
			value = 256,
			tooltip = "Never load/save settings in .ini file",
			active = false,
		},
		NoScrollbar = {
			value = 8,
			tooltip = "Disable scrollbars (window can still scroll with mouse or programmatically)",
			active = false,
		},
		NoScrollWithMouse = {
			value = 16,
			tooltip = "Disable user vertically scrolling with mouse wheel. On child window, mouse wheel will be",
			active = false,
		},
		NoTitleBar = {
			value = 1,
			tooltip = "Disable title-bar",
			active = false,
		},
		Popup = {
			value = 67108864,
			tooltip = "Don't use! For internal use by BeginPopup()",
			active = false,
		},
		Tooltip = {
			value = 33554432,
			tooltip = "Don't use! For internal use by BeginTooltip()",
			active = false,
		},
	}




ButtonFlags.MouseButtonMask_ = {
	value = ButtonFlags["MouseButtonLeft"]["value"]
		+ ButtonFlags["MouseButtonRight"]["value"]
		+ ButtonFlags["MouseButtonMiddle"]["value"],
	tooltip = "",
	active = false,
}



ColorEditFlags.DataTypeMask_ = {
	value = ColorEditFlags["Uint8"]["value"] + ColorEditFlags["Float"]["value"],
	tooltip = "",
	active = false,
}

ColorEditFlags.DefaultOptions_ = {
	value = ColorEditFlags["Uint8"]["value"]
		+ ColorEditFlags["DisplayRGB"]["value"]
		+ ColorEditFlags["InputRGB"]["value"]
		+ ColorEditFlags["PickerHueBar"]["value"],
	tooltip = "",
	active = false,
}

ColorEditFlags.DisplayMask_ = {
	value = ColorEditFlags["DisplayRGB"]["value"]
		+ ColorEditFlags["DisplayHSV"]["value"]
		+ ColorEditFlags["DisplayHex"]["value"],
	tooltip = "",
	active = false,
}

ColorEditFlags.InputMask_ = {
	value = ColorEditFlags["InputRGB"]["value"] + ColorEditFlags["InputHSV"]["value"],
	tooltip = "",
	active = false,
}

ColorEditFlags.PickerMask_ = {
	value = ColorEditFlags["PickerHueWheel"]["value"] + ColorEditFlags["PickerHueBar"]["value"],
	tooltip = "",
	active = false,
}

ComboFlags.HeightMask_ = {
	value = ComboFlags["HeightSmall"]["value"]
		+ ComboFlags["HeightRegular"]["value"]
		+ ComboFlags["HeightLarge"]["value"]
		+ ComboFlags["HeightLargest"]["value"],
	tooltip = "",
	active = false,
}

-- DebugLogFlags.EventMask_ = {
--     value = DebugLogFlags.EventActiveId .value + DebugLogFlags["EventFocus"]["value"] + DebugLogFlags["EventPopup"]["value"] + DebugLogFlags["EventNav"]["value"] + DebugLogFlags["EventClipper"]["value"] + DebugLogFlags["EventSelection"]["value"] + DebugLogFlags["EventIO"]["value"],
--     tooltip = "",
--     active = false,
-- }

DragDropFlags.AcceptPeekOnly = {
	value = DragDropFlags["AcceptBeforeDelivery"]["value"] + DragDropFlags["AcceptNoDrawDefaultRect"]["value"],
	tooltip = "For peeking ahead and inspecting the payload before delivery.",
	active = false,
}

FocusedFlags.RootAndChildWindows = {
	value = FocusedFlags["RootWindow"]["value"] + FocusedFlags["ChildWindows"]["value"],
	tooltip = "",
	active = false,
}



HoveredFlags.RootAndChildWindows = {
	value = HoveredFlags["RootWindow"]["value"] + HoveredFlags["ChildWindows"]["value"],
	tooltip = "",
	active = false,
}



InputTextFlags.EnterReturnsTrue = {
	value = 32,
	tooltip = "Return 'true' when Enter is pressed (as opposed to every time the value was modified). Consider looking at the IsItemDeactivatedAfterEdit() function.",
	active = false,
}



return {
	ActivateFlags = ActivateFlags,
	BackendFlags = BackendFlags,
	ButtonFlags = ButtonFlags,
	ChildFlags = ChildFlags,
	ColorEditFlags = ColorEditFlags,
	ComboFlags = ComboFlags,
	Cond = Cond,
	DockNodeFlags = DockNodeFlags,
	-- DebugLogFlags = DebugLogFlags ,
	DragDropFlags = DragDropFlags,
	FocusedFlags = FocusedFlags,
	FocusRequestFlags = FocusRequestFlags,
	HoveredFlags = HoveredFlags,
	InputFlags = InputFlags,
	InputTextFlags = InputTextFlags,
	ItemFlags = ItemFlags,
	ItemStatusFlags = ItemStatusFlags,
	NavHighlightFlags = NavHighlightFlags,
	NavMoveFlags = NavMoveFlags,
	NextItemDataFlags = NextItemDataFlags,
	NextWindowDataFlags = NextWindowDataFlags,
	OldColumnFlags = OldColumnFlags,
	PopupFlags = PopupFlags,
	ScrollFlags = ScrollFlags,
	SelectableFlags = SelectableFlags,
	SeparatorFlags = SeparatorFlags,
	SliderFlags = SliderFlags,
	TabBarFlags = TabBarFlags,
	TabItemFlags = TabItemFlags,
	TableColumnFlags = TableColumnFlags,
	TableFlags = TableFlags,
	TableRowFlags = TableRowFlags,
	TextFlags = TextFlags,
	TooltipFlags = TooltipFlags,
	TreeNodeFlags = TreeNodeFlags,
	WindowFlags = WindowFlags,
}

else
	local ActivateFlags = {
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		PreferInput = {
			value = 1,
			tooltip = "Favor activation that requires keyboard text input (e.g. for Slider/Drag). Default for Enter key.",
			active = false,
		},
		PreferTweak = {
			value = 2,
			tooltip = "Favor activation for tweaking with arrows or gamepad (e.g. for Slider/Drag). Default for Space key and if keyboard is not used.",
			active = false,
		},
		TryToPreserveState = {
			value = 4,
			tooltip = "Request widget to preserve state if it can (e.g. InputText will try to preserve cursor/selection)",
			active = false,
		},
	}
	local ButtonFlags = {
		AlignTextBaseLine = {
			value = 32768,
			tooltip = "vertically align button to match text baseline - ButtonEx() only",
			active = false,
		},
		AllowOverlap = {
			value = 4096,
			tooltip = "require previous frame HoveredId to either match id or be null before being usable.",
			active = false,
		},
		DontClosePopups = {
			value = 8192,
			tooltip = "disable automatically closing parent popup on press //",
			active = false,
		},
		FlattenChildren = {
			value = 2048,
			tooltip = "allow interactions even if a child window is overlapping",
			active = false,
		},
		MouseButtonLeft = {
			value = 1,
			tooltip = "React on left mouse button (default)",
			active = false,
		},
		MouseButtonMiddle = {
			value = 4,
			tooltip = "React on center mouse button",
			active = false,
		},
		MouseButtonRight = {
			value = 2,
			tooltip = "React on right mouse button",
			active = false,
		},
		NoHoldingActiveId = {
			value = 131072,
			tooltip = "don't set ActiveId while holding the mouse (ImGuiButtonFlags_PressedOnClick only)",
			active = false,
		},
		NoHoveredOnFocus = {
			value = 524288,
			tooltip = "don't report as hovered when nav focus is on this item",
			active = false,
		},
		NoKeyModifiers = {
			value = 65536,
			tooltip = "disable mouse interaction if a key modifier is held",
			active = false,
		},
		NoNavFocus = {
			value = 262144,
			tooltip = "don't override navigation focus when activated (FIXME: this is essentially used everytime an item uses ImGuiItemFlags_NoNav, but because legacy specs don't requires LastItemData to be set ButtonBehavior(), we can't poll g.LastItemData.InFlags ",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoSetKeyOwner = {
			value = 1048576,
			tooltip = "don't set key/input owner on the initial click (note: mouse buttons are keys! often, the key in question will be ImGuiKey_MouseLeft!)",
			active = false,
		},
		NoTestKeyOwner = {
			value = 2097152,
			tooltip = "don't test key/input owner when polling the key (note: mouse buttons are keys! often, the key in question will be ImGuiKey_MouseLeft!)",
			active = false,
		},
		PressedOnClick = {
			value = 16,
			tooltip = "return true on click (mouse down event)",
			active = false,
		},
		PressedOnClickRelease = {
			value = 32,
			tooltip = "return true on click + release on same item <-- this is what the majority of Button are using",
			active = false,
		},
		PressedOnClickReleaseAnywhere = {
			value = 64,
			tooltip = "return true on click + release even if the release event is not done while hovering the item",
			active = false,
		},
		PressedOnDefault_ = {
			value = nil,
			tooltip = "",
			active = false,
		},
		PressedOnDoubleClick = {
			value = 256,
			tooltip = "return true on double-click (default requires click+release)",
			active = false,
		},
		PressedOnDragDropHold = {
			value = 512,
			tooltip = "return true when held into while we are drag and dropping another item (used by e.g. tree nodes, collapsing headers)",
			active = false,
		},
		PressedOnRelease = {
			value = 128,
			tooltip = "return true on release (default requires click+release)",
			active = false,
		},
		Repeat = {
			value = 1024,
			tooltip = "hold to repeat",
			active = false,
		},
	}
	local ColorEditFlags = {
		AlphaBar = {
			value = 65536,
			tooltip = "ColorEdit, ColorPicker: show vertical alpha bar/gradient in picker.",
			active = false,
		},
		AlphaPreview = {
			value = 131072,
			tooltip = "ColorEdit, ColorPicker, ColorButton: display preview as a transparent color over a checkerboard, instead of opaque.",
			active = false,
		},
		AlphaPreviewHalf = {
			value = 262144,
			tooltip = "ColorEdit, ColorPicker, ColorButton: display half opaque / half checkerboard, instead of opaque.",
			active = false,
		},
		DisplayHex = {
			value = 4194304,
			tooltip = '"',
			active = false,
		},
		DisplayHSV = {
			value = 2097152,
			tooltip = '"',
			active = false,
		},
		DisplayRGB = {
			value = 1048576,
			tooltip = "ColorEdit: override _display_ type among RGB/HSV/Hex. ColorPicker: select any combination using one or more of RGB/HSV/Hex.",
			active = false,
		},
		Float = {
			value = 16777216,
			tooltip = "ColorEdit, ColorPicker, ColorButton: _display_ values formatted as 0.0f. 1.0f floats instead of 0..255 integers. No round-trip of value via integers.",
			active = false,
		},
		HDR = {
			value = 524288,
			tooltip = "(WIP) ColorEdit: Currently only disable 0.0f. 1.0f limits in RGBA edition (note: you probably want to use ImGuiColorEditFlags_Float flag as well).",
			active = false,
		},
		InputHSV = {
			value = 268435456,
			tooltip = "ColorEdit, ColorPicker: input and output data in HSV format.",
			active = false,
		},
		InputRGB = {
			value = 134217728,
			tooltip = "ColorEdit, ColorPicker: input and output data in RGB format.",
			active = false,
		},
		NoAlpha = {
			value = 2,
			tooltip = "ColorEdit, ColorPicker, ColorButton: ignore Alpha component (will only read 3 components from the input pointer).",
			active = false,
		},
		NoBorder = {
			value = 1024,
			tooltip = "ColorButton: disable border (which is enforced by default)",
			active = false,
		},
		NoDragDrop = {
			value = 512,
			tooltip = "ColorEdit: disable drag and drop target. ColorButton: disable drag and drop source.",
			active = false,
		},
		NoInputs = {
			value = 32,
			tooltip = "ColorEdit, ColorPicker: disable inputs sliders/text widgets (e.g. to show only the small preview color square).",
			active = false,
		},
		NoLabel = {
			value = 128,
			tooltip = "ColorEdit, ColorPicker: disable display of inline text label (the label is still forwarded to the tooltip and picker).",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoOptions = {
			value = 8,
			tooltip = "ColorEdit: disable toggling options menu when right-clicking on inputs/small preview.",
			active = false,
		},
		NoPicker = {
			value = 4,
			tooltip = "ColorEdit: disable picker when clicking on color square.",
			active = false,
		},
		NoSidePreview = {
			value = 256,
			tooltip = "ColorPicker: disable bigger color preview on right side of the picker, use small color square preview instead.",
			active = false,
		},
		NoSmallPreview = {
			value = 16,
			tooltip = "ColorEdit, ColorPicker: disable color square preview next to the inputs. (e.g. to show only the inputs)",
			active = false,
		},
		NoTooltip = {
			value = 64,
			tooltip = "ColorEdit, ColorPicker, ColorButton: disable tooltip when hovering the preview.",
			active = false,
		},
		PickerHueBar = {
			value = 33554432,
			tooltip = "ColorPicker: bar for Hue, rectangle for Sat/Value.",
			active = false,
		},
		PickerHueWheel = {
			value = 67108864,
			tooltip = "ColorPicker: wheel for Hue, triangle for Sat/Value.",
			active = false,
		},
		Uint8 = {
			value = 8388608,
			tooltip = "ColorEdit, ColorPicker, ColorButton: _display_ values formatted as 0..255 ",
			active = false,
		},
	}
	local ComboFlags = {
		CustomPreview = {
			value = 1048576,
			tooltip = "enable BeginComboPreview()",
			active = false,
		},
		HeightLarge = {
			value = 8,
			tooltip = "Max ~20 items visible",
			active = false,
		},
		HeightLargest = {
			value = 16,
			tooltip = "As many fitting items as possible",
			active = false,
		},
		HeightRegular = {
			value = 4,
			tooltip = "Max ~8 items visible (default)",
			active = false,
		},
		HeightSmall = {
			value = 2,
			tooltip = "Max ~4 items visible. Tip: If you want your combo popup to be a specific size you can use SetNextWindowSizeConstraints() prior to calling BeginCombo()",
			active = false,
		},
		NoArrowButton = {
			value = 32,
			tooltip = "Display on the preview box without the square arrow button",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoPreview = {
			value = 64,
			tooltip = "Display only a square arrow button",
			active = false,
		},
		PopupAlignLeft = {
			value = 1,
			tooltip = "Align the popup toward the left by default",
			active = false,
		},
	}
	local Cond = {
		Always = {
			value = 1,
			tooltip = "No condition (always set the variable), same as _None",
			active = false,
		},
		Appearing = {
			value = 8,
			tooltip = "Set the variable if the object/window is appearing after being hidden/inactive (or the first time)",
			active = false,
		},
		FirstUseEver = {
			value = 4,
			tooltip = "Set the variable if the object/window has no persistently saved data (no entry in .ini file)",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "No condition (always set the variable), same as _Always",
			active = false,
		},
		Once = {
			value = 2,
			tooltip = "Set the variable once per runtime session (only the first call will succeed)",
			active = false,
		},
	}
	-- local DebugLogFlags = {
	--         EventActiveId = {
	--             value = 1,
	--             tooltip = "",
	--             active = false,
	--         },
	--         EventClipper = {
	--             value = 16,
	--             tooltip = "",
	--             active = false,
	--         },
	--         EventFocus = {
	--             value = 2,
	--             tooltip = "",
	--             active = false,
	--         },
	--         EventIO = {
	--             value = 64,
	--             tooltip = "",
	--             active = false,
	--         },
	--         EventNav = {
	--             value = 8,
	--             tooltip = "",
	--             active = false,
	--         },
	--         EventPopup = {
	--             value = 4,
	--             tooltip = "",
	--             active = false,
	--         },
	--         EventSelection = {
	--             value = 32,
	--             tooltip = "",
	--             active = false,
	--         },
	--         None = {
	--             value = 0,
	--             tooltip = "",
	--             active = false,
	--         },
	--         OutputToTTY = {
	--             value = 1024,
	--             tooltip = "Also send output to TTY",
	--             active = false,
	--         },
	--     }
	local DragDropFlags = {
		AcceptBeforeDelivery = {
			value = 1024,
			tooltip = "AcceptDragDropPayload() will returns true even before the mouse button is released. You can then call IsDelivery() to test if the payload needs to be delivered.",
			active = false,
		},
		AcceptNoDrawDefaultRect = {
			value = 2048,
			tooltip = "Do not draw the default highlight rectangle when hovering over target.",
			active = false,
		},
		AcceptNoPreviewTooltip = {
			value = 4096,
			tooltip = "Request hiding the BeginDragDropSource tooltip from the BeginDragDropTarget site.",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		SourceAllowNullID = {
			value = 8,
			tooltip = "Allow items such as Text(), Image() that have no unique identifier to be used as drag source, by manufacturing a temporary identifier based on their window-relative position. This is extremely unusual within the dear imgui ecosystem and so we made it explicit.",
			active = false,
		},
		SourceAutoExpirePayload = {
			value = 32,
			tooltip = "Automatically expire the payload if the source cease to be submitted (otherwise payloads are persisting while being dragged)",
			active = false,
		},
		SourceExtern = {
			value = 16,
			tooltip = "External source (from outside of dear imgui), won't attempt to read current item/window info. Will always return true. Only one Extern source can be active simultaneously.",
			active = false,
		},
		SourceNoDisableHover = {
			value = 2,
			tooltip = "By default, when dragging we clear data so that IsItemHovered() will return false, to avoid subsequent user code submitting tooltips. This flag disables this behavior so you can still call IsItemHovered() on the source item.",
			active = false,
		},
		SourceNoHoldToOpenOthers = {
			value = 4,
			tooltip = "Disable the behavior that allows to open tree nodes and collapsing header by holding over them while dragging a source item.",
			active = false,
		},
		SourceNoPreviewTooltip = {
			value = 1,
			tooltip = "Disable preview tooltip. By default, a successful call to BeginDragDropSource opens a tooltip so you can display a preview or description of the source contents. This flag disables this behavior.",
			active = false,
		},
	}
	local FocusedFlags = {
		AnyWindow = {
			value = 4,
			tooltip = "Return true if any window is focused. Important: If you are trying to tell how to dispatch your low-level inputs, do NOT use this. Use 'io.WantCaptureMouse' instead! Please read the FAQ!",
			active = false,
		},
		ChildWindows = {
			value = 1,
			tooltip = "Return true if any children of the window is focused",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoPopupHierarchy = {
			value = 8,
			tooltip = "Do not consider popup hierarchy (do not treat popup emitter as parent of popup) (when used with _ChildWindows or _RootWindow)",
			active = false,
		},
		RootWindow = {
			value = 2,
			tooltip = "Test from root window (top most parent of the current hierarchy)",
			active = false,
		},
	}
	local FocusRequestFlags = {
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		RestoreFocusedChild = {
			value = 1,
			tooltip = "Find last focused child (if any) and focus it instead.",
			active = false,
		},
		UnlessBelowModal = {
			value = 2,
			tooltip = "Do not set focus if the window is below a modal.",
			active = false,
		},
	}
	local HoveredFlags = {
		AllowWhenBlockedByActiveItem = {
			value = 128,
			tooltip = "Return true even if an active item is blocking access to this item/window. Useful for Drag and Drop patterns.",
			active = false,
		},
		AllowWhenBlockedByPopup = {
			value = 32,
			tooltip = "Return true even if a popup window is normally blocking access to this item/window",
			active = false,
		},
		AllowWhenDisabled = {
			value = 1024,
			tooltip = "IsItemHovered() only: Return true even if the item is disabled",
			active = false,
		},
		AllowWhenOverlappedByItem = {
			value = 256,
			tooltip = "IsItemHovered() only: Return true even if the item uses AllowOverlap mode and is overlapped by another hoverable item.",
			active = false,
		},
		AllowWhenOverlappedByWindow = {
			value = 512,
			tooltip = "IsItemHovered() only: Return true even if the position is obstructed or overlapped by another window.",
			active = false,
		},
		AnyWindow = {
			value = 4,
			tooltip = "IsWindowHovered() only: Return true if any window is hovered",
			active = false,
		},
		ChildWindows = {
			value = 1,
			tooltip = "IsWindowHovered() only: Return true if any children of the window is hovered",
			active = false,
		},
		DelayNone = {
			value = 16384,
			tooltip = "IsItemHovered() only: Return true immediately (default). As this is the default you generally ignore this.",
			active = false,
		},
		DelayNormal = {
			value = 65536,
			tooltip = "IsItemHovered() only: Return true after style.HoverDelayNormal elapsed (~0.40 sec) (shared between items) + requires mouse to be stationary for style.HoverStationaryDelay (once per item).",
			active = false,
		},
		DelayShort = {
			value = 32768,
			tooltip = "IsItemHovered() only: Return true after style.HoverDelayShort elapsed (~0.15 sec) (shared between items) + requires mouse to be stationary for style.HoverStationaryDelay (once per item).",
			active = false,
		},
		ForTooltip = {
			value = 4096,
			tooltip = "Shortcut for standard flags when using IsItemHovered() + SetTooltip() sequence.",
			active = false,
		},
		NoNavOverride = {
			value = 2048,
			tooltip = "IsItemHovered() only: Disable using gamepad/keyboard navigation state when active, always query mouse",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "Return true if directly over the item/window, not obstructed by another window, not obstructed by an active popup or modal blocking inputs under them.",
			active = false,
		},
		NoPopupHierarchy = {
			value = 8,
			tooltip = "IsWindowHovered() only: Do not consider popup hierarchy (do not treat popup emitter as parent of popup) (when used with _ChildWindows or _RootWindow)",
			active = false,
		},
		NoSharedDelay = {
			value = 131072,
			tooltip = "IsItemHovered() only: Disable shared delay system where moving from one item to the next keeps the previous timer for a short time (standard for tooltips with long delays)",
			active = false,
		},
		RootWindow = {
			value = 2,
			tooltip = "IsWindowHovered() only: Test from root window (top most parent of the current hierarchy)",
			active = false,
		},
		Stationary = {
			value = 8192,
			tooltip = "Require mouse to be stationary for style.HoverStationaryDelay (~0.15 sec) _at least one time_. After this, can move on same item/window. Using the stationary test tends to reduces the need for a long delay.",
			active = false,
		},
	}
	local InputFlags = {
		CondActive = {
			value = 32,
			tooltip = "Only set if item is active (default to both)",
			active = false,
		},
		CondHovered = {
			value = 16,
			tooltip = "Only set if item is hovered (default to both)",
			active = false,
		},
		LockThisFrame = {
			value = 64,
			tooltip = "Access to key data will require EXPLICIT owner ID (ImGuiKeyOwner_Any/0 will NOT accepted for polling). Cleared at end of frame. This is useful to make input-owner-aware code steal keys from non-input-owner-aware code.",
			active = false,
		},
		LockUntilRelease = {
			value = 128,
			tooltip = "Access to key data will require EXPLICIT owner ID (ImGuiKeyOwner_Any/0 will NOT accepted for polling). Cleared when the key is released or at end of each frame if key is released. This is useful to make input-owner-aware code steal keys from non-input-owner-aware code.",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		Repeat = {
			value = 1,
			tooltip = "Return true on successive repeats. Default for legacy IsKeyPressed(). NOT Default for legacy IsMouseClicked(). MUST BE == 1.",
			active = false,
		},
		RepeatRateDefault = {
			value = 2,
			tooltip = "Repeat rate: Regular (default)",
			active = false,
		},
		RepeatRateNavMove = {
			value = 4,
			tooltip = "Repeat rate: Fast",
			active = false,
		},
		RepeatRateNavTweak = {
			value = 8,
			tooltip = "Repeat rate: Faster",
			active = false,
		},
		RouteAlways = {
			value = 4096,
			tooltip = "Do not register route, poll keys directly.",
			active = false,
		},
		RouteFocused = {
			value = 256,
			tooltip = "(Default) Register focused route: Accept inputs if window is in focus stack. Deep-most focused window takes inputs. ActiveId takes inputs over deep-most focused window.",
			active = false,
		},
		RouteGlobal = {
			value = 1024,
			tooltip = "Register route globally (medium priority: unless an active item registered the route, e.g. CTRL+A registered by InputText).",
			active = false,
		},
		RouteGlobalHigh = {
			value = 2048,
			tooltip = "Register route globally (highest priority: unlikely you need to use that: will interfere with every active items)",
			active = false,
		},
		RouteGlobalLow = {
			value = 512,
			tooltip = "Register route globally (lowest priority: unless a focused window or active item registered the route) -> recommended Global priority.",
			active = false,
		},
		RouteUnlessBgFocused = {
			value = 8192,
			tooltip = "Global routes will not be applied if underlying background/void is focused (== no Dear ImGui windows are focused). Useful for overlay applications.",
			active = false,
		},
	}
	local InputTextFlags = {
		AllowTabInput = {
			value = 1024,
			tooltip = "Pressing TAB input a '\\t' character into the text field",
			active = false,
		},
		AlwaysOverwrite = {
			value = 8192,
			tooltip = "Overwrite mode",
			active = false,
		},
		AutoSelectAll = {
			value = 16,
			tooltip = "Select entire text when first taking mouse focus",
			active = false,
		},
		CallbackAlways = {
			value = 256,
			tooltip = "Callback on each iteration. User code may query cursor position, modify text buffer.",
			active = false,
		},
		CallbackCharFilter = {
			value = 512,
			tooltip = "Callback on character inputs to replace or discard them. Modify 'EventChar' to replace or discard, or return 1 in callback to discard.",
			active = false,
		},
		CallbackCompletion = {
			value = 64,
			tooltip = "Callback on pressing TAB (for completion handling)",
			active = false,
		},
		CallbackEdit = {
			value = 524288,
			tooltip = "Callback on any edit (note that InputText() already returns true on edit, the callback is useful mainly to manipulate the underlying buffer while focus is active)",
			active = false,
		},
		CallbackHistory = {
			value = 128,
			tooltip = "Callback on pressing Up/Down arrows (for history handling)",
			active = false,
		},
		CallbackResize = {
			value = 262144,
			tooltip = "Callback on buffer capacity changes request (beyond 'buf_size' parameter value), allowing the string to grow. Notify when the string wants to be resized (for string types which hold a cache of their Size). You will be provided a new BufSize in the callback and NEED to honor it. (see misc/cpp/imgui_stdlib.h for an example of using this)",
			active = false,
		},
		CharsDecimal = {
			value = 1,
			tooltip = "Allow 0123456789.+-*/",
			active = false,
		},
		CharsHexadecimal = {
			value = 2,
			tooltip = "Allow 0123456789ABCDEFabcdef",
			active = false,
		},
		CharsNoBlank = {
			value = 8,
			tooltip = "Filter out spaces, tabs",
			active = false,
		},
		CharsScientific = {
			value = 131072,
			tooltip = "Allow 0123456789.+-*/eE (Scientific notation input)",
			active = false,
		},
		CharsUppercase = {
			value = 4,
			tooltip = "Turn a..z into A..Z",
			active = false,
		},
		CtrlEnterForNewLine = {
			value = 2048,
			tooltip = "In multi-line mode, unfocus with Enter, add new line with Ctrl+Enter (default is opposite: unfocus with Ctrl+Enter, add line with Enter).",
			active = false,
		},
		EscapeClearsAll = {
			value = 1048576,
			tooltip = "Escape key clears content if not empty, and deactivate otherwise (contrast to default behavior of Escape to revert)",
			active = false,
		},
		MergedItem = {
			value = 268435456,
			tooltip = "For internal use by TempInputText(), will skip calling ItemAdd(). Require bounding-box to strictly match.",
			active = false,
		},
		Multiline = {
			value = 67108864,
			tooltip = "For internal use by InputTextMultiline()",
			active = false,
		},
		NoHorizontalScroll = {
			value = 4096,
			tooltip = "Disable following the cursor horizontally",
			active = false,
		},

		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoUndoRedo = {
			value = 65536,
			tooltip = "Disable undo/redo. Note that input text owns the text data while active, if you want to provide your own undo/redo stack you need e.g. to call ClearActiveID().",
			active = false,
		},
		Password = {
			value = 32768,
			tooltip = "Password mode, display all characters as '*'",
			active = false,
		},
		ReadOnly = {
			value = 16384,
			tooltip = "Read-only mode",
			active = false,
		},
	}
	local ItemFlags = {
		AllowOverlap = {
			value = 512,
			tooltip = "Allow being overlapped by another widget. Not-hovered to Hovered transition deferred by a frame.",
			active = false,
		},
		ButtonRepeat = {
			value = 2,
			tooltip = "Button() will return true multiple times based on io.KeyRepeatDelay and io.KeyRepeatRate settings.",
			active = false,
		},
		Disabled = {
			value = 4,
			tooltip = "Disable interactions but doesn't affect visuals. See BeginDisabled()/EndDisabled(). See github.com/ocornut/imgui/issues/211",
			active = false,
		},
		Inputable = {
			value = 1024,
			tooltip = "Auto-activate input mode when tab focused. Currently only used and supported by a few items before it becomes a generic feature.",
			active = false,
		},
		MixedValue = {
			value = 64,
			tooltip = "Represent a mixed/indeterminate value, generally multi-selection where values differ. Currently only supported by Checkbox() (later should support all sorts of widgets)",
			active = false,
		},
		NoNav = {
			value = 8,
			tooltip = "Disable any form of focusing (keyboard/gamepad directional navigation and SetKeyboardFocusHere() calls)",
			active = false,
		},
		NoNavDefaultFocus = {
			value = 16,
			tooltip = "Disable item being a candidate for default focus (e.g. used by title bar items)",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoTabStop = {
			value = 1,
			tooltip = 'Disable keyboard tabbing. This is a "lighter" version of ImGuiItemFlags_NoNav.',
			active = false,
		},
		NoWindowHoverableCheck = {
			value = 256,
			tooltip = "Disable hoverable check in ItemHoverable()",
			active = false,
		},
		ReadOnly = {
			value = 128,
			tooltip = "Allow hovering interactions but underlying value is not changed.",
			active = false,
		},
		SelectableDontClosePopup = {
			value = 32,
			tooltip = "Disable MenuItem/Selectable() automatically closing their popup window",
			active = false,
		},
	}
	local ItemStatusFlags = {
		Checkable = {
			value = 4194304,
			tooltip = "Item is a checkable (e.g. CheckBox, MenuItem)",
			active = false,
		},
		Checked = {
			value = 8388608,
			tooltip = "Checked status",
			active = false,
		},
		Deactivated = {
			value = 64,
			tooltip = "Only valid if ImGuiItemStatusFlags_HasDeactivated is set.",
			active = false,
		},
		Edited = {
			value = 4,
			tooltip = "Value exposed by item was edited in the current frame (should match the bool return value of most widgets)",
			active = false,
		},
		FocusedByTabbing = {
			value = 256,
			tooltip = "Set when the Focusable item just got focused by Tabbing (FIXME: to be removed soon)",
			active = false,
		},
		HasDeactivated = {
			value = 32,
			tooltip = "Set if the widget/group is able to provide data for the ImGuiItemStatusFlags_Deactivated flag.",
			active = false,
		},
		HasDisplayRect = {
			value = 2,
			tooltip = "g.LastItemData.DisplayRect is valid",
			active = false,
		},
		HoveredRect = {
			value = 1,
			tooltip = "Mouse position is within item rectangle (does NOT mean that the window is in correct z-order and can be hovered!, this is only one part of the most-common IsItemHovered test)",
			active = false,
		},
		HoveredWindow = {
			value = 128,
			tooltip = "Override the HoveredWindow test to allow cross-window hover testing.",
			active = false,
		},
		Inputable = {
			value = 16777216,
			tooltip = "Item is a text-inputable (e.g. InputText, SliderXXX, DragXXX)",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		Openable = {
			value = 1048576,
			tooltip = "Item is an openable (e.g. TreeNode)",
			active = false,
		},
		Opened = {
			value = 2097152,
			tooltip = "Opened status",
			active = false,
		},
		ToggledOpen = {
			value = 16,
			tooltip = "Set when TreeNode() reports toggling their open state.",
			active = false,
		},
		ToggledSelection = {
			value = 8,
			tooltip = 'Set when Selectable(), TreeNode() reports toggling a selection. We can\'t report "Selected", only state changes, in order to easily handle clipping with less issues.',
			active = false,
		},
		Visible = {
			value = 512,
			tooltip = "Set when item is overlapping the current clipping rectangle (Used internally. Please don't use yet: API/system will change as we refactor Itemadd()).",
			active = false,
		},
	}
	local NavHighlightFlags = {
		AlwaysDraw = {
			value = 4,
			tooltip = "Draw rectangular highlight if (g.NavId == id) _even_ when using the mouse.",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoRounding = {
			value = 8,
			tooltip = "",
			active = false,
		},
		TypeDefault = {
			value = 1,
			tooltip = "",
			active = false,
		},
		TypeThin = {
			value = 2,
			tooltip = "",
			active = false,
		},
	}
	local NavMoveFlags = {
		Activate = {
			value = 4096,
			tooltip = "Activate/select target item.",
			active = false,
		},
		AllowCurrentNavId = {
			value = 16,
			tooltip = "Allow scoring and considering the current NavId as a move target candidate. This is used when the move source is offset (e.g. pressing PageDown actually needs to send a Up move request, if we are pressing PageDown from the bottom-most item we need to stay in place)",
			active = false,
		},
		AlsoScoreVisibleSet = {
			value = 32,
			tooltip = "Store alternate result in NavMoveResultLocalVisible that only comprise elements that are already fully visible (used by PageUp/PageDown)",
			active = false,
		},
		DebugNoResult = {
			value = 256,
			tooltip = "Dummy scoring for debug purpose, don't apply result",
			active = false,
		},
		FocusApi = {
			value = 512,
			tooltip = "Requests from focus API can land/focus/activate items even if they are marked with _NoTabStop (see NavProcessItemForTabbingRequest() for details)",
			active = false,
		},
		Forwarded = {
			value = 128,
			tooltip = "",
			active = false,
		},
		IsPageMove = {
			value = 2048,
			tooltip = "Identify a PageDown/PageUp request.",
			active = false,
		},
		IsTabbing = {
			value = 1024,
			tooltip = "== Focus + Activate if item is Inputable + DontChangeNavHighlight",
			active = false,
		},
		LoopX = {
			value = 1,
			tooltip = "On failed request, restart from opposite side",
			active = false,
		},
		LoopY = {
			value = 2,
			tooltip = "",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoSelect = {
			value = 8192,
			tooltip = "Don't trigger selection by not setting g.NavJustMovedTo",
			active = false,
		},
		NoSetNavHighlight = {
			value = 16384,
			tooltip = "Do not alter the visible state of keyboard vs mouse nav highlight",
			active = false,
		},
		ScrollToEdgeY = {
			value = 64,
			tooltip = "Force scrolling to min/max (used by Home",
			active = false,
		},
		WrapX = {
			value = 4,
			tooltip = "On failed request, request from opposite side one line down (when NavDir==right) or one line up (when NavDir==left)",
			active = false,
		},
		WrapY = {
			value = 8,
			tooltip = "This is not super useful but provided for completeness",
			active = false,
		},
	}
	local NextItemDataFlags = {
		HasOpen = {
			value = 2,
			tooltip = "",
			active = false,
		},
		HasWidth = {
			value = 1,
			tooltip = "",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
	}
	local NextWindowDataFlags = {
		HasBgAlpha = {
			value = 64,
			tooltip = "",
			active = false,
		},
		HasCollapsed = {
			value = 8,
			tooltip = "",
			active = false,
		},
		HasContentSize = {
			value = 4,
			tooltip = "",
			active = false,
		},
		HasFocus = {
			value = 32,
			tooltip = "",
			active = false,
		},
		HasPos = {
			value = 1,
			tooltip = "",
			active = false,
		},
		HasScroll = {
			value = 128,
			tooltip = "",
			active = false,
		},
		HasSize = {
			value = 2,
			tooltip = "",
			active = false,
		},
		HasSizeConstraint = {
			value = 16,
			tooltip = "",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
	}
	local OldColumnFlags = {
		GrowParentContentsSize = {
			value = 16,
			tooltip = "(WIP) Restore pre-1.51 behavior of extending the parent window contents size but _without affecting the columns width at all_. Will eventually remove.",
			active = false,
		},
		NoBorder = {
			value = 1,
			tooltip = "Disable column dividers",
			active = false,
		},
		NoForceWithinWindow = {
			value = 8,
			tooltip = "Disable forcing columns to fit within window",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoPreserveWidths = {
			value = 4,
			tooltip = "Disable column width preservation when adjusting columns",
			active = false,
		},
		NoResize = {
			value = 2,
			tooltip = "Disable resizing columns when clicking on the dividers",
			active = false,
		},
	}
	local PopupFlags = {
		AnyPopupId = {
			value = 128,
			tooltip = "For IsPopupOpen(): ignore the ImGuiID parameter and test for any popup.",
			active = false,
		},
		AnyPopupLevel = {
			value = 256,
			tooltip = "For IsPopupOpen(): search/test at any level of the popup stack (default test in the current level)",
			active = false,
		},
		MouseButtonDefault_ = {
			value = 1,
			tooltip = "",
			active = false,
		},
		MouseButtonLeft = {
			value = 0,
			tooltip = "For BeginPopupContext*(): open on Left Mouse release. Guaranteed to always be == 0 (same as ImGuiMouseButton_Left)",
			active = false,
		},
		MouseButtonMiddle = {
			value = 2,
			tooltip = "For BeginPopupContext*(): open on Middle Mouse release. Guaranteed to always be == 2 (same as ImGuiMouseButton_Middle)",
			active = false,
		},
		MouseButtonRight = {
			value = 1,
			tooltip = "For BeginPopupContext*(): open on Right Mouse release. Guaranteed to always be == 1 (same as ImGuiMouseButton_Right)",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoOpenOverExistingPopup = {
			value = 32,
			tooltip = "For OpenPopup*(), BeginPopupContext*(): don't open if there's already a popup at the same level of the popup stack",
			active = false,
		},
		NoOpenOverItems = {
			value = 64,
			tooltip = "For BeginPopupContextWindow(): don't return true when hovering items, only when hovering empty space",
			active = false,
		},
	}
	local ScrollFlags = {
		AlwaysCenterX = {
			value = 16,
			tooltip = "Always center the result item on X axis ",
			active = false,
		},
		AlwaysCenterY = {
			value = 32,
			tooltip = "Always center the result item on Y axis  Y axis for appearing window)",
			active = false,
		},
		KeepVisibleCenterX = {
			value = 4,
			tooltip = "If item is not visible: scroll to make the item centered on X axis ",
			active = false,
		},
		KeepVisibleCenterY = {
			value = 8,
			tooltip = "If item is not visible: scroll to make the item centered on Y axis",
			active = false,
		},
		KeepVisibleEdgeX = {
			value = 1,
			tooltip = "If item is not visible: scroll as little as possible on X axis to bring item back into view  X axis",
			active = false,
		},
		KeepVisibleEdgeY = {
			value = 2,
			tooltip = "If item is not visible: scroll as little as possible on Y axis to bring item back into view  Y axis for windows that are already visible",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
	}
	local SelectableFlags = {
		AllowDoubleClick = {
			value = 4,
			tooltip = "Generate press events on double clicks too",
			active = false,
		},
		AllowItemOverlap = {
			value = nil,
			tooltip = "Renamed in 1.89.7",
			active = false,
		},
		AllowOverlap = {
			value = 16,
			tooltip = "(WIP) Hit testing to allow subsequent widgets to overlap this one",
			active = false,
		},
		Disabled = {
			value = 8,
			tooltip = "Cannot be selected, display grayed out text",
			active = false,
		},
		DontClosePopups = {
			value = 1,
			tooltip = "Clicking this doesn't close parent popup window",
			active = false,
		},
		NoHoldingActiveID = {
			value = 1048576,
			tooltip = "",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoPadWithHalfSpacing = {
			value = 67108864,
			tooltip = "Disable padding each side with ItemSpacing * 0.5f",
			active = false,
		},
		NoSetKeyOwner = {
			value = 134217728,
			tooltip = "Don't set key/input owner on the initial click (note: mouse buttons are keys! often, the key in question will be ImGuiKey_MouseLeft!)",
			active = false,
		},
		SelectOnClick = {
			value = 4194304,
			tooltip = "Override button behavior to react on Click (default is Click+Release)",
			active = false,
		},
		SelectOnNav = {
			value = 2097152,
			tooltip = "(WIP) Auto-select when moved into. This is not exposed in public API as to handle multi-select and modifiers we will need user to explicitly control focus scope. May be replaced with a BeginSelection() API.",
			active = false,
		},
		SelectOnRelease = {
			value = 8388608,
			tooltip = "Override button behavior to react on Release (default is Click+Release)",
			active = false,
		},
		SetNavIdOnHover = {
			value = 33554432,
			tooltip = "Set Nav/Focus ID on mouse hover (used by MenuItem)",
			active = false,
		},
		SpanAllColumns = {
			value = 2,
			tooltip = "Selectable frame can span all columns (text will still fit in current column)",
			active = false,
		},
		SpanAvailWidth = {
			value = 16777216,
			tooltip = "Span all avail width even if we declared less for layout purpose. FIXME: We may be able to remove this (added in 6251d379, 2bcafc86 for menus)",
			active = false,
		},
	}
	local SeparatorFlags = {
		Horizontal = {
			value = 1,
			tooltip = "Axis default to current layout type, so generally Horizontal unless e.g. in a menu bar",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		SpanAllColumns = {
			value = 4,
			tooltip = "Make separator cover all columns of a legacy Columns() set.",
			active = false,
		},
		Vertical = {
			value = 2,
			tooltip = "",
			active = false,
		},
	}
	local SliderFlags = {
		AlwaysClamp = {
			value = 16,
			tooltip = "Clamp value to min/max bounds when input manually with CTRL+Click. By default CTRL+Click allows going out of bounds.",
			active = false,
		},
		Logarithmic = {
			value = 32,
			tooltip = "Make the widget logarithmic (linear otherwise). Consider using ImGuiSliderFlags_NoRoundToFormat with this if using a format-string with small amount of digits.",
			active = false,
		},
		NoInput = {
			value = 128,
			tooltip = "Disable CTRL+Click or Enter key allowing to input text directly into the widget",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoRoundToFormat = {
			value = 64,
			tooltip = "Disable rounding underlying value to match precision of the display format string (e.g. %.3f values are rounded to those 3 digits)",
			active = false,
		},
		ReadOnly = {
			value = 2097152,
			tooltip = "Consider using g.NextItemData.ItemFlags |= ImGuiItemFlags_ReadOnly instead.",
			active = false,
		},
		Vertical = {
			value = 1048576,
			tooltip = "Should this slider be orientated vertically?",
			active = false,
		},
	}
	local TabBarFlags = {
		AutoSelectNewTabs = {
			value = 2,
			tooltip = "Automatically select new tabs when they appear",
			active = false,
		},
		DockNode = {
			value = 1048576,
			tooltip = "Part of a dock node 't use this in the master branch but it facilitate branch syncing to keep this around",
			active = false,
		},
		FittingPolicyDefault_ = {
			value = nil,
			tooltip = "",
			active = false,
		},
		FittingPolicyResizeDown = {
			value = 64,
			tooltip = "Resize tabs when they don't fit",
			active = false,
		},
		FittingPolicyScroll = {
			value = 128,
			tooltip = "Add scroll buttons when tabs don't fit",
			active = false,
		},
		IsFocused = {
			value = 2097152,
			tooltip = "",
			active = false,
		},
		NoCloseWithMiddleMouseButton = {
			value = 8,
			tooltip = "Disable behavior of closing tabs (that are submitted with p_open != NULL) with middle mouse button. You can still repro this behavior on user's side with if (IsItemHovered() && IsMouseClicked(2)) *p_open = false.",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoTabListScrollingButtons = {
			value = 16,
			tooltip = "Disable scrolling buttons (apply when fitting policy is ImGuiTabBarFlags_FittingPolicyScroll)",
			active = false,
		},
		NoTooltip = {
			value = 32,
			tooltip = "Disable tooltips when hovering a tab",
			active = false,
		},
		Reorderable = {
			value = 1,
			tooltip = "Allow manually dragging tabs to re-order them + New tabs are appended at the end of list",
			active = false,
		},
		SaveSettings = {
			value = 4194304,
			tooltip = "FIXME: Settings are handled by the docking system, this only request the tab bar to mark settings dirty when reordering tabs",
			active = false,
		},
		TabListPopupButton = {
			value = 4,
			tooltip = "Disable buttons to open the tab list popup",
			active = false,
		},
	}
	local TabItemFlags = {
		Button = {
			value = 2097152,
			tooltip = "Used by TabItemButton, change the tab item behavior to mimic a button",
			active = false,
		},
		Leading = {
			value = 64,
			tooltip = "Enforce the tab position to the left of the tab bar (after the tab list popup button)",
			active = false,
		},
		NoCloseButton = {
			value = 1048576,
			tooltip = "Track whether p_open was set or not (we'll need this info on the next frame to recompute ContentWidth during layout)",
			active = false,
		},
		NoCloseWithMiddleMouseButton = {
			value = 4,
			tooltip = "Disable behavior of closing tabs (that are submitted with p_open != NULL) with middle mouse button. You can still repro this behavior on user's side with if (IsItemHovered() && IsMouseClicked(2)) *p_open = false.",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoPushId = {
			value = 8,
			tooltip = "Don't call PushID(tab->ID)/PopID() on BeginTabItem()/EndTabItem()",
			active = false,
		},
		NoReorder = {
			value = 32,
			tooltip = "Disable reordering this tab or having another tab cross over this tab",
			active = false,
		},
		NoTooltip = {
			value = 16,
			tooltip = "Disable tooltip for the given tab",
			active = false,
		},
		SetSelected = {
			value = 2,
			tooltip = "Trigger flag to programmatically make the tab selected when calling BeginTabItem()",
			active = false,
		},
		Trailing = {
			value = 128,
			tooltip = "Enforce the tab position to the right of the tab bar (before the scrolling buttons)",
			active = false,
		},
		UnsavedDocument = {
			value = 1,
			tooltip = "Display a dot next to the title + tab is selected when clicking the X + closure is not assumed (will wait for user to stop submitting the tab). Otherwise closure is assumed when pressing the X, so if you keep submitting the tab may reappear at end of tab bar.",
			active = false,
		},
	}
	local TableColumnFlags = {
		DefaultHide = {
			value = 2,
			tooltip = "Default as a hidden/disabled column.",
			active = false,
		},
		DefaultSort = {
			value = 4,
			tooltip = "Default as a sorting column.",
			active = false,
		},
		Disabled = {
			value = 1,
			tooltip = "Overriding/master disable flag: hide column, won't show in context menu (unlike calling TableSetColumnEnabled() which manipulates the user accessible state)",
			active = false,
		},
		IndentDisable = {
			value = 131072,
			tooltip = "Ignore current Indent value when entering cell (default for columns > 0). Indentation changes _within_ the cell will still be honored.",
			active = false,
		},
		IndentEnable = {
			value = 65536,
			tooltip = "Use current Indent value when entering cell (default for column 0).",
			active = false,
		},
		IsEnabled = {
			value = 16777216,
			tooltip = 'Status: is enabled == not hidden by user/api (referred to as "Hide" in _DefaultHide and _NoHide) flags.',
			active = false,
		},
		IsHovered = {
			value = 134217728,
			tooltip = "Status: is hovered by mouse",
			active = false,
		},
		IsSorted = {
			value = 67108864,
			tooltip = "Status: is currently part of the sort specs",
			active = false,
		},
		IsVisible = {
			value = 33554432,
			tooltip = "Status: is visible == is enabled AND not clipped by scrolling.",
			active = false,
		},
		NoClip = {
			value = 256,
			tooltip = "Disable clipping for this column (all NoClip columns will render in a same draw command).",
			active = false,
		},
		NoDirectResize_ = {
			value = 1073741824,
			tooltip = "Disable user resizing this column directly (it may however we resized indirectly from its left edge)",
			active = false,
		},
		NoHeaderLabel = {
			value = 4096,
			tooltip = "TableHeadersRow() will not submit label for this column. Convenient for some small columns. Name will still appear in context menu.",
			active = false,
		},
		NoHeaderWidth = {
			value = 8192,
			tooltip = "Disable header text width contribution to automatic column width.",
			active = false,
		},
		NoHide = {
			value = 128,
			tooltip = "Disable ability to hide/disable this column.",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoReorder = {
			value = 64,
			tooltip = "Disable manual reordering this column, this will also prevent other columns from crossing over this column.",
			active = false,
		},
		NoResize = {
			value = 32,
			tooltip = "Disable manual resizing.",
			active = false,
		},
		NoSort = {
			value = 512,
			tooltip = "Disable ability to sort on this field (even if ImGuiTableFlags_Sortable is set on the table).",
			active = false,
		},
		NoSortAscending = {
			value = 1024,
			tooltip = "Disable ability to sort in the ascending direction.",
			active = false,
		},
		NoSortDescending = {
			value = 2048,
			tooltip = "Disable ability to sort in the descending direction.",
			active = false,
		},
		PreferSortAscending = {
			value = 16384,
			tooltip = "Make the initial sort direction Ascending when first sorting on this column (default).",
			active = false,
		},
		PreferSortDescending = {
			value = 32768,
			tooltip = "Make the initial sort direction Descending when first sorting on this column.",
			active = false,
		},
		WidthFixed = {
			value = 16,
			tooltip = "Column will not stretch. Preferable with horizontal scrolling enabled (default if table sizing policy is _SizingFixedFit and table is resizable).",
			active = false,
		},
		WidthStretch = {
			value = 8,
			tooltip = "Column will stretch. Preferable with horizontal scrolling disabled (default if table sizing policy is _SizingStretchSame or _SizingStretchProp).",
			active = false,
		},
	}
	local TableFlags = {
		BordersInnerH = {
			value = 128,
			tooltip = "Draw horizontal borders between rows.",
			active = false,
		},
		BordersInnerV = {
			value = 512,
			tooltip = "Draw vertical borders between columns.",
			active = false,
		},
		BordersOuterH = {
			value = 256,
			tooltip = "Draw horizontal borders at the top and bottom.",
			active = false,
		},
		BordersOuterV = {
			value = 1024,
			tooltip = "Draw vertical borders on the left and right sides.",
			active = false,
		},
		ContextMenuInBody = {
			value = 32,
			tooltip = "Right-click on columns body/contents will display table context menu. By default it is available in TableHeadersRow().",
			active = false,
		},
		Hideable = {
			value = 4,
			tooltip = "Enable hiding/disabling columns in context menu.",
			active = false,
		},
		NoBordersInBody = {
			value = 2048,
			tooltip = "Disable vertical borders in columns Body (borders will always appear in Headers). -> May move to style",
			active = false,
		},
		NoBordersInBodyUntilResize = {
			value = 4096,
			tooltip = "Disable vertical borders in columns Body until hovered for resize (borders will always appear in Headers). -> May move to style",
			active = false,
		},
		NoClip = {
			value = 1048576,
			tooltip = "Disable clipping rectangle for every individual columns (reduce draw command count, items will be able to overflow into other columns). Generally incompatible with TableSetupScrollFreeze().",
			active = false,
		},
		NoHostExtendX = {
			value = 65536,
			tooltip = "Make outer width auto-fit to columns, overriding outer_size.x value. Only available when ScrollX/ScrollY are disabled and Stretch columns are not used.",
			active = false,
		},
		NoHostExtendY = {
			value = 131072,
			tooltip = "Make outer height stop exactly at outer_size.y (prevent auto-extending table past the limit). Only available when ScrollX/ScrollY are disabled. Data below the limit will be clipped and not visible.",
			active = false,
		},
		NoKeepColumnsVisible = {
			value = 262144,
			tooltip = "Disable keeping column always minimally visible when ScrollX is off and table gets too small. Not recommended if columns are resizable.",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoPadInnerX = {
			value = 8388608,
			tooltip = "Disable inner padding between columns (double inner padding if BordersOuterV is on, single inner padding if BordersOuterV is off).",
			active = false,
		},
		NoPadOuterX = {
			value = 4194304,
			tooltip = "Default if BordersOuterV is off. Disable outermost padding.",
			active = false,
		},
		NoSavedSettings = {
			value = 16,
			tooltip = "Disable persisting columns order, width and sort settings in the .ini file.",
			active = false,
		},
		PadOuterX = {
			value = 2097152,
			tooltip = "Default if BordersOuterV is on. Enable outermost padding. Generally desirable if you have headers.",
			active = false,
		},
		PreciseWidths = {
			value = 524288,
			tooltip = "Disable distributing remainder width to stretched columns (width allocation on a 100-wide table with 3 columns: Without this flag: 33,33,34. With this flag: 33,33,33). With larger number of columns, resizing will appear to be less smooth.",
			active = false,
		},
		Reorderable = {
			value = 2,
			tooltip = "Enable reordering columns in header row (need calling TableSetupColumn() + TableHeadersRow() to display headers)",
			active = false,
		},
		Resizable = {
			value = 1,
			tooltip = "Enable resizing columns.",
			active = false,
		},
		RowBg = {
			value = 64,
			tooltip = "Set each RowBg color with ImGuiCol_TableRowBg or ImGuiCol_TableRowBgAlt (equivalent of calling TableSetBgColor with ImGuiTableBgFlags_RowBg0 on each row manually)",
			active = false,
		},
		ScrollX = {
			value = 16777216,
			tooltip = "Enable horizontal scrolling. Require 'outer_size' parameter of BeginTable() to specify the container size. Changes default sizing policy. Because this creates a child window, ScrollY is currently generally recommended when using ScrollX.",
			active = false,
		},
		ScrollY = {
			value = 33554432,
			tooltip = "Enable vertical scrolling. Require 'outer_size' parameter of BeginTable() to specify the container size.",
			active = false,
		},
		SizingFixedFit = {
			value = 8192,
			tooltip = "Columns default to _WidthFixed or _WidthAuto (if resizable or not resizable), matching contents width.",
			active = false,
		},
		SizingFixedSame = {
			value = 16384,
			tooltip = "Columns default to _WidthFixed or _WidthAuto (if resizable or not resizable), matching the maximum contents width of all columns. Implicitly enable ImGuiTableFlags_NoKeepColumnsVisible.",
			active = false,
		},
		SizingStretchProp = {
			value = 24576,
			tooltip = "Columns default to _WidthStretch with default weights proportional to each columns contents widths.",
			active = false,
		},
		SizingStretchSame = {
			value = 32768,
			tooltip = "Columns default to _WidthStretch with default weights all equal, unless overridden by TableSetupColumn().",
			active = false,
		},
		Sortable = {
			value = 8,
			tooltip = "Enable sorting. Call TableGetSortSpecs() to obtain sort specs. Also see ImGuiTableFlags_SortMulti and ImGuiTableFlags_SortTristate.",
			active = false,
		},
		SortMulti = {
			value = 67108864,
			tooltip = "Hold shift when clicking headers to sort on multiple column. TableGetSortSpecs() may return specs where (SpecsCount > 1).",
			active = false,
		},
		SortTristate = {
			value = 134217728,
			tooltip = "Allow no sorting, disable default sorting. TableGetSortSpecs() may return specs where (SpecsCount == 0).",
			active = false,
		},
	}
	local TableRowFlags = {
		Headers = {
			value = 1,
			tooltip = "Identify header row (set default background color + width of its contents accounted differently for auto column width)",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
	}
	local TextFlags = {
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoWidthForLargeClippedText = {
			value = 1,
			tooltip = "",
			active = false,
		},
	}
	local TooltipFlags = {
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		OverridePrevious = {
			value = 2,
			tooltip = "Clear/ignore previously submitted tooltip (defaults to ap",
			active = false,
		},
	}
	local TreeNodeFlags = {
		AllowItemOverlap = {
			value = nil,
			tooltip = "Renamed in 1.89.7",
			active = false,
		},
		AllowOverlap = {
			value = 4,
			tooltip = "Hit testing to allow subsequent widgets to overlap this one",
			active = false,
		},
		Bullet = {
			value = 512,
			tooltip = "Display a bullet instead of arrow. IMPORTANT: node can still be marked open/close if you don't set the _Leaf flag!",
			active = false,
		},
		ClipLabelForTrailingButton = {
			value = 1048576,
			tooltip = "",
			active = false,
		},
		DefaultOpen = {
			value = 32,
			tooltip = "Default node to be open",
			active = false,
		},
		Framed = {
			value = 2,
			tooltip = "Draw frame with background (e.g. for CollapsingHeader)",
			active = false,
		},
		FramePadding = {
			value = 1024,
			tooltip = "Use FramePadding (even for an unframed text node) to vertically align text baseline to regular widget height. Equivalent to calling AlignTextToFramePadding().",
			active = false,
		},
		Leaf = {
			value = 256,
			tooltip = "No collapsing, no arrow (use as a convenience for leaf nodes).",
			active = false,
		},
		NavLeftJumpsBackHere = {
			value = 8192,
			tooltip = "(WIP) Nav: left direction may move to this TreeNode() from any of its child (items submitted between TreeNode and TreePop)",
			active = false,
		},
		NoAutoOpenOnLog = {
			value = 16,
			tooltip = "Don't automatically and temporarily open node when Logging is active (by default logging will automatically open tree nodes)",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoTreePushOnOpen = {
			value = 8,
			tooltip = "Don't do a TreePush() when open (e.g. for CollapsingHeader) = no extra indent nor pushing on ID stack",
			active = false,
		},
		OpenOnArrow = {
			value = 128,
			tooltip = "Only open when clicking on the arrow part. If ImGuiTreeNodeFlags_OpenOnDoubleClick is also set, single-click arrow or double-click all box to open.",
			active = false,
		},
		OpenOnDoubleClick = {
			value = 64,
			tooltip = "Need double-click to open node",
			active = false,
		},
		Selected = {
			value = 1,
			tooltip = "Draw as selected",
			active = false,
		},
		SpanAvailWidth = {
			value = 2048,
			tooltip = "Extend hit box to the right-most edge, even if not framed. This is not the default in order to allow adding other items on the same line. In the future we may refactor the hit system to be front-to-back, allowing natural overlaps and then this can become the default.",
			active = false,
		},
		SpanFullWidth = {
			value = 4096,
			tooltip = "Extend hit box to the left-most and right-most edges (bypass the indented area).",
			active = false,
		},
		UpsideDownArrow = {
			value = 2097152,
			tooltip = "(FIXME-WIP) Turn Down arrow into an Up arrow, but reversed trees (#6517)",
			active = false,
		},
	}
	local WindowFlags = {
		AlwaysAutoResize = {
			value = 64,
			tooltip = "Resize every window to its content every frame",
			active = false,
		},
		AlwaysHorizontalScrollbar = {
			value = 32768,
			tooltip = "Always show horizontal scrollbar (even if ContentSize.x < Size.x)",
			active = false,
		},
		AlwaysUseWindowPadding = {
			value = 65536,
			tooltip = "Ensure child windows without border uses style.WindowPadding (ignored by default for non-bordered child windows, because more convenient)",
			active = false,
		},
		AlwaysVerticalScrollbar = {
			value = 16384,
			tooltip = "Always show vertical scrollbar (even if ContentSize.y < Size.y)",
			active = false,
		},
		ChildMenu = {
			value = 268435456,
			tooltip = "Don't use! For internal use by BeginMenu()",
			active = false,
		},
		ChildWindow = {
			value = 16777216,
			tooltip = "Don't use! For internal use by BeginChild()",
			active = false,
		},
		HorizontalScrollbar = {
			value = 2048,
			tooltip = 'Allow horizontal scrollbar to appear (off by default). You may use SetNextWindowContentSize(ImVec2(width,0.0f)); prior to calling Begin() to specify width. Read code in imgui_demo in the "Horizontal Scrolling" section.',
			active = false,
		},
		MenuBar = {
			value = 1024,
			tooltip = "Has a menu-bar",
			active = false,
		},
		Modal = {
			value = 134217728,
			tooltip = "Don't use! For internal use by BeginPopupModal()",
			active = false,
		},
		NavFlattened = {
			value = 8388608,
			tooltip = "On child window: allow gamepad/keyboard navigation to cross over parent border to this child or between sibling child windows.",
			active = false,
		},
		NoBackground = {
			value = 128,
			tooltip = "Disable drawing background color (WindowBg, etc.) and outside border. Similar as using SetNextWindowBgAlpha(0.0f).",
			active = false,
		},
		NoBringToFrontOnFocus = {
			value = 8192,
			tooltip = "Disable bringing window to front when taking focus (e.g. clicking on it or programmatically giving it focus)",
			active = false,
		},
		NoCollapse = {
			value = 32,
			tooltip = "Disable user collapsing window by double-clicking on it. Also referred to as Window Menu Button (e.g. within a docking node).",
			active = false,
		},
		NoFocusOnAppearing = {
			value = 4096,
			tooltip = "Disable taking focus when transitioning from hidden to visible state",
			active = false,
		},
		NoMouseInputs = {
			value = 512,
			tooltip = "Disable catching mouse, hovering test with pass through.",
			active = false,
		},
		NoMove = {
			value = 4,
			tooltip = "Disable user moving the window",
			active = false,
		},
		NoNavFocus = {
			value = 524288,
			tooltip = "No focusing toward this window with gamepad/keyboard navigation (e.g. skipped by CTRL+TAB)",
			active = false,
		},
		NoNavInputs = {
			value = 262144,
			tooltip = "No gamepad/keyboard navigation within the window",
			active = false,
		},
		None = {
			value = 0,
			tooltip = "",
			active = false,
		},
		NoResize = {
			value = 2,
			tooltip = "Disable user resizing with the lower-right grip",
			active = false,
		},
		NoSavedSettings = {
			value = 256,
			tooltip = "Never load/save settings in .ini file",
			active = false,
		},
		NoScrollbar = {
			value = 8,
			tooltip = "Disable scrollbars (window can still scroll with mouse or programmatically)",
			active = false,
		},
		NoScrollWithMouse = {
			value = 16,
			tooltip = "Disable user vertically scrolling with mouse wheel. On child window, mouse wheel will be forwarded to the parent unless NoScrollbar is also set.",
			active = false,
		},
		NoTitleBar = {
			value = 1,
			tooltip = "Disable title-bar",
			active = false,
		},
		Popup = {
			value = 67108864,
			tooltip = "Don't use! For internal use by BeginPopup()",
			active = false,
		},
		Tooltip = {
			value = 33554432,
			tooltip = "Don't use! For internal use by BeginTooltip()",
			active = false,
		},
		UnsavedDocument = {
			value = 1048576,
			tooltip = "Display a dot next to the title. When used in a tab/docking context, tab is selected when clicking the X + closure is not assumed (will wait for user to stop submitting the tab). Otherwise closure is assumed when pressing the X, so if you keep submitting the tab may reappear at end of tab bar.",
			active = false,
		},
	}

	ButtonFlags.MouseButtonMask_ = {
		value = ButtonFlags["MouseButtonLeft"]["value"]
			+ ButtonFlags["MouseButtonRight"]["value"]
			+ ButtonFlags["MouseButtonMiddle"]["value"],
		tooltip = "",
		active = false,
	}

	ButtonFlags.PressedOnMask_ = {
		value = ButtonFlags["PressedOnClick"]["value"]
			+ ButtonFlags["PressedOnClickRelease"]["value"]
			+ ButtonFlags["PressedOnClickReleaseAnywhere"]["value"]
			+ ButtonFlags["PressedOnRelease"]["value"]
			+ ButtonFlags["PressedOnDoubleClick"]["value"]
			+ ButtonFlags["PressedOnDragDropHold"]["value"],
		tooltip = "",
		active = false,
	}

	ColorEditFlags.DataTypeMask_ = {
		value = ColorEditFlags["Uint8"]["value"] + ColorEditFlags["Float"]["value"],
		tooltip = "",
		active = false,
	}

	ColorEditFlags.DefaultOptions_ = {
		value = ColorEditFlags["Uint8"]["value"]
			+ ColorEditFlags["DisplayRGB"]["value"]
			+ ColorEditFlags["InputRGB"]["value"]
			+ ColorEditFlags["PickerHueBar"]["value"],
		tooltip = "",
		active = false,
	}

	ColorEditFlags.DisplayMask_ = {
		value = ColorEditFlags["DisplayRGB"]["value"]
			+ ColorEditFlags["DisplayHSV"]["value"]
			+ ColorEditFlags["DisplayHex"]["value"],
		tooltip = "",
		active = false,
	}

	ColorEditFlags.InputMask_ = {
		value = ColorEditFlags["InputRGB"]["value"] + ColorEditFlags["InputHSV"]["value"],
		tooltip = "",
		active = false,
	}

	ColorEditFlags.PickerMask_ = {
		value = ColorEditFlags["PickerHueWheel"]["value"] + ColorEditFlags["PickerHueBar"]["value"],
		tooltip = "",
		active = false,
	}

	ComboFlags.HeightMask_ = {
		value = ComboFlags["HeightSmall"]["value"]
			+ ComboFlags["HeightRegular"]["value"]
			+ ComboFlags["HeightLarge"]["value"]
			+ ComboFlags["HeightLargest"]["value"],
		tooltip = "",
		active = false,
	}

	-- DebugLogFlags.EventMask_ = {
	--     value = DebugLogFlags.EventActiveId .value + DebugLogFlags["EventFocus"]["value"] + DebugLogFlags["EventPopup"]["value"] + DebugLogFlags["EventNav"]["value"] + DebugLogFlags["EventClipper"]["value"] + DebugLogFlags["EventSelection"]["value"] + DebugLogFlags["EventIO"]["value"],
	--     tooltip = "",
	--     active = false,
	-- }

	DragDropFlags.AcceptPeekOnly = {
		value = DragDropFlags["AcceptBeforeDelivery"]["value"] + DragDropFlags["AcceptNoDrawDefaultRect"]["value"],
		tooltip = "For peeking ahead and inspecting the payload before delivery.",
		active = false,
	}

	FocusedFlags.RootAndChildWindows = {
		value = FocusedFlags["RootWindow"]["value"] + FocusedFlags["ChildWindows"]["value"],
		tooltip = "",
		active = false,
	}
	HoveredFlags.AllowWhenOverlapped = {
		value = HoveredFlags["AllowWhenOverlappedByItem"]["value"] + HoveredFlags["AllowWhenOverlappedByWindow"]["value"],
		tooltip = "",
		active = false,
	}
	HoveredFlags.DelayMask_ = {
		value = HoveredFlags["DelayNone"]["value"]
			+ HoveredFlags["DelayShort"]["value"]
			+ HoveredFlags["DelayNormal"]["value"]
			+ HoveredFlags["NoSharedDelay"]["value"],
		tooltip = "",
		active = false,
	}

	HoveredFlags.AllowedMaskForIsItemHovered = {
		value = HoveredFlags["AllowWhenBlockedByPopup"]["value"]
			+ HoveredFlags["AllowWhenBlockedByActiveItem"]["value"]
			+ HoveredFlags["AllowWhenOverlapped"]["value"]
			+ HoveredFlags["AllowWhenDisabled"]["value"]
			+ HoveredFlags["NoNavOverride"]["value"]
			+ HoveredFlags["ForTooltip"]["value"]
			+ HoveredFlags["Stationary"]["value"]
			+ HoveredFlags["DelayMask_"]["value"],
		tooltip = "",
		active = false,
	}

	HoveredFlags.AllowedMaskForIsWindowHovered = {
		value = HoveredFlags["ChildWindows"]["value"]
			+ HoveredFlags["RootWindow"]["value"]
			+ HoveredFlags["AnyWindow"]["value"]
			+ HoveredFlags["NoPopupHierarchy"]["value"]
			+ HoveredFlags["AllowWhenBlockedByPopup"]["value"]
			+ HoveredFlags["AllowWhenBlockedByActiveItem"]["value"]
			+ HoveredFlags["ForTooltip"]["value"]
			+ HoveredFlags["Stationary"]["value"],
		tooltip = "",
		active = false,
	}

	HoveredFlags.RectOnly = {
		value = HoveredFlags["AllowWhenBlockedByPopup"]["value"]
			+ HoveredFlags["AllowWhenBlockedByActiveItem"]["value"]
			+ HoveredFlags["AllowWhenOverlapped"]["value"],
		tooltip = "",
		active = false,
	}

	HoveredFlags.RootAndChildWindows = {
		value = HoveredFlags["RootWindow"]["value"] + HoveredFlags["ChildWindows"]["value"],
		tooltip = "",
		active = false,
	}

	InputFlags.CondDefault_ = {
		value = InputFlags["CondHovered"]["value"] + InputFlags["CondActive"]["value"],
		tooltip = "",
		active = false,
	}

	InputFlags.CondMask_ = {
		value = InputFlags["CondHovered"]["value"] + InputFlags["CondActive"]["value"],
		tooltip = "",
		active = false,
	}

	InputFlags.RepeatRateMask_ = {
		value = InputFlags["RepeatRateDefault"]["value"]
			+ InputFlags["RepeatRateNavMove"]["value"]
			+ InputFlags["RepeatRateNavTweak"]["value"],
		tooltip = "",
		active = false,
	}

	InputFlags.RouteExtraMask_ = {
		value = InputFlags["RouteAlways"]["value"] + InputFlags["RouteUnlessBgFocused"]["value"],
		tooltip = "",
		active = false,
	}

	InputFlags.RouteMask_ = {
		value = InputFlags["RouteFocused"]["value"]
			+ InputFlags["RouteGlobal"]["value"]
			+ InputFlags["RouteGlobalLow"]["value"]
			+ InputFlags["RouteGlobalHigh"]["value"],
		tooltip = "_Always not part of this!",
		active = false,
	}

	InputFlags.SupportedBySetKeyOwner = {
		value = InputFlags["LockThisFrame"]["value"] + InputFlags["LockUntilRelease"]["value"],
		tooltip = "",
		active = false,
	}

	InputFlags.SupportedByIsKeyPressed = {
		value = InputFlags["Repeat"]["value"] + InputFlags["RepeatRateMask_"]["value"],
		tooltip = "",
		active = false,
	}

	InputFlags.SupportedBySetItemKeyOwner = {
		value = InputFlags["SupportedBySetKeyOwner"]["value"] + InputFlags["CondMask_"]["value"],
		tooltip = "",
		active = false,
	}

	InputFlags.SupportedByShortcut = {
		value = InputFlags["Repeat"]["value"]
			+ InputFlags["RepeatRateMask_"]["value"]
			+ InputFlags["RouteMask_"]["value"]
			+ InputFlags["RouteExtraMask_"]["value"],
		tooltip = "",
		active = false,
	}
	InputTextFlags.EnterReturnsTrue = {
		value = 32,
		tooltip = "Return 'true' when Enter is pressed (as opposed to every time the value was modified). Consider looking at the IsItemDeactivatedAfterEdit() function.",
		active = false,
	}

	PopupFlags.AnyPopup = {
		value = PopupFlags["AnyPopupId"]["value"] + PopupFlags["AnyPopupLevel"]["value"],
		tooltip = "",
		active = false,
	}

	ScrollFlags.MaskX_ = {
		value = ScrollFlags["KeepVisibleEdgeX"]["value"]
			+ ScrollFlags["KeepVisibleCenterX"]["value"]
			+ ScrollFlags["AlwaysCenterX"]["value"],
		tooltip = "",
		active = false,
	}

	ScrollFlags.MaskY_ = {
		value = ScrollFlags["KeepVisibleEdgeY"]["value"]
			+ ScrollFlags["KeepVisibleCenterY"]["value"]
			+ ScrollFlags["AlwaysCenterY"]["value"],
		tooltip = "",
		active = false,
	}

	WindowFlags.NoDecoration = {
		value = WindowFlags["NoTitleBar"]["value"]
			+ WindowFlags["NoResize"]["value"]
			+ WindowFlags["NoScrollbar"]["value"]
			+ WindowFlags["NoCollapse"]["value"],
		tooltip = "",
		active = false,
	}

	WindowFlags.NoInputs = {
		value = WindowFlags["NoMouseInputs"]["value"]
			+ WindowFlags["NoNavInputs"]["value"]
			+ WindowFlags["NoNavFocus"]["value"],
		tooltip = "",
		active = false,
	}

	WindowFlags.NoNav = {
		value = WindowFlags["NoNavInputs"]["value"] + WindowFlags["NoNavFocus"]["value"],
		tooltip = "",
		active = false,
	}
	return {
		ActivateFlags = ActivateFlags,
		ButtonFlags = ButtonFlags,
		ColorEditFlags = ColorEditFlags,
		ComboFlags = ComboFlags,
		Cond = Cond,
		-- DebugLogFlags = DebugLogFlags ,
		DragDropFlags = DragDropFlags,
		FocusedFlags = FocusedFlags,
		FocusRequestFlags = FocusRequestFlags,
		HoveredFlags = HoveredFlags,
		InputFlags = InputFlags,
		InputTextFlags = InputTextFlags,
		ItemFlags = ItemFlags,
		ItemStatusFlags = ItemStatusFlags,
		NavHighlightFlags = NavHighlightFlags,
		NavMoveFlags = NavMoveFlags,
		NextItemDataFlags = NextItemDataFlags,
		NextWindowDataFlags = NextWindowDataFlags,
		OldColumnFlags = OldColumnFlags,
		PopupFlags = PopupFlags,
		ScrollFlags = ScrollFlags,
		SelectableFlags = SelectableFlags,
		SeparatorFlags = SeparatorFlags,
		SliderFlags = SliderFlags,
		TabBarFlags = TabBarFlags,
		TabItemFlags = TabItemFlags,
		TableColumnFlags = TableColumnFlags,
		TableFlags = TableFlags,
		TableRowFlags = TableRowFlags,
		TextFlags = TextFlags,
		TooltipFlags = TooltipFlags,
		TreeNodeFlags = TreeNodeFlags,
		WindowFlags = WindowFlags,
	}
	end
