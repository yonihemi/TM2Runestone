import Foundation

/// Not a complete representation of tmThemes, just what can currently be represented as a runestonetheme.
/// Reference: http://www.sublimetext.com/docs/color_schemes_tmtheme.html
public struct TMTheme: Decodable {
	public let name: String
	let globalSettings: GlobalSettings
	let scopeStyles: [TMScopeStyle]
	let semanticClass: String?
}

/// In theory, this may be a hex string or x11 color.
/// In practice though themes in the wild contain a valid hex so we don't bother with conversions.
/// `typealias`ed here in case some conversion logic is ever needed.
typealias Color = String

struct GlobalSettings: Decodable {
	/// The default background color
	let background: Color?
	/// The default color for text
	let foreground: Color
	
	/// The color of the caret
	let caret: Color?
	
	/// he background color of the line containing the caret.
	let lineHighlight: Color?
	
	let invisibles: Color?
	
	/// The background color of selected text
	let selection: Color?
	
	/// A color that will override the scope-based text color of the selection
	let selectionForeground: Color?
	
	/// The color for the border of the selection
	let selectionBorder: Color?
	
	///  The background color of a selection in a view that is not currently focused
	let inactiveSelection: Color?
	
	/// A color that will override the scope-based text color of the selection in a view that is not currently focused
	let inactiveSelectionForeground: Color?
	
	/// The background color of the gutter
	var gutter: Color?
	
	/// The color of line numbers in the gutter
	let gutterForeground: Color?
	
	/// The color used to draw indent guides. Only used if the option "draw_normal" is present in the setting indent_guide_options.
	let guide: Color?
	
	/// The color used to draw the indent guides for the indentation levels containing the caret. Only used if the option "draw_active" is present in the setting indent_guide_options.
	let activeguide: Color?
}

struct TMFontStyle: RawRepresentable, Decodable {
	let bold: Bool
	let italic: Bool
	let underline: Bool
	
	init?(rawValue: String) {
		let components = rawValue.split(separator: " ", omittingEmptySubsequences: true)
		var bold = false, italic = false, underline = false
		for component in components {
			switch component {
			case "bold":
				bold = true
			case "italic":
				italic = true
			case "underline":
				underline = true
			case "normal":
				break
			default:
				return nil
			}
		}
		self.bold = bold
		self.italic = italic
		self.underline = underline
	}
	
	var rawValue: String {
		var components = [String]()
		if bold { components.append("bold") }
		if italic { components.append("italic") }
		if underline { components.append("underline") }
		return components.joined(separator: " ")
	}
}

struct ScopeSettings: Decodable {
	let background: Color?
	let foreground: Color?
	let fontStyle: TMFontStyle?
}

struct TMScopeStyle: Decodable {
	let name: String?
	let scope: String
	let settings: ScopeSettings
}

extension TMTheme {
	private enum CodingKeys: String, CodingKey {
		case name
		case settings
		case semanticClass
	}
	
	private struct GlobalSettingsWrapper: Decodable {
		let settings: GlobalSettings
	}
	
	/// A dummy to advance `nestedUnkeyedContainer` in case of failure
	private struct Empty: Decodable { }
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decode(String.self, forKey: .name)
		self.semanticClass = (try? container.decode(String.self, forKey: .semanticClass)) ?? nil

		var settings = try container.nestedUnkeyedContainer(forKey: .settings)
		self.globalSettings = try settings.decode(GlobalSettingsWrapper.self).settings
		
		var scopes = [TMScopeStyle]()
		while !settings.isAtEnd {
			if let scopeStyle = try? settings.decode(TMScopeStyle.self) {
				scopes.append(scopeStyle)
			} else {
				// Be reselient to malformed scopes, e.g. https://github.com/Colorsublime/Colorsublime-Themes/blob/98d89d261d0b5971091a9f2fcd2ebf7e439762b1/themes/Amy.tmTheme#L456
				_ = try settings.decode(Empty.self)
			}
		}
		self.scopeStyles = scopes
	}
	
	public init(contentsOf url: URL) throws {
		let themeData = try Data(contentsOf: url)
		let decoder = PropertyListDecoder()
		self = try decoder.decode(TMTheme.self, from: themeData)
	}
	
	func estimateAppearance() -> Appearance {
		if let semanticClass = semanticClass,
		   semanticClass.hasPrefix("theme.dark.") { return .dark }
		let lowerecaseName = name.lowercased()
		if lowerecaseName.contains("dark") { return .dark }
		if lowerecaseName.contains("dimmed") { return .dark }
		// TODO: determine by background color
		return .light
	}
}
