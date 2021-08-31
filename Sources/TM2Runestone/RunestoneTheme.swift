import Foundation

/// A partial representation of a Runestone Theme, excluding `interface` settings
struct RunestoneTheme: Encodable {
	let editor: Editor
	let scopes: [Scope]
}

public enum Appearance: String, Encodable {
	case light
	case dark
}

enum ScrollIndicatorStyle: String, Encodable {
	case white
	case black
}

struct Gutter: Encodable {
	let background: Color
	let hairline: Color
	let lineNumber: Color
	let selectedLinesBackground: Color
	let selectedLinesLineNumber: Color
}

struct PageGuide: Encodable {
	let background: Color
	let hairline: Color
}

struct Editor: Encodable {
	let text: Color
	let background: Color
	let caret: Color
	let invisibleCharacters: Color
	let selectedLineBackground: Color
	let scrollIndicatorStyle: ScrollIndicatorStyle
	let gutter: Gutter
	let pageGuide: PageGuide
}

enum FontWeight: String, Encodable {
	case regular
	case bold
}

enum FontStyle: String, Encodable {
	case regular
	case italic
}

struct Scope: Encodable {
	let name: String
	let color: Color
	let fontWeight: FontWeight?
	let fontStyle: FontStyle?
}

extension RunestoneTheme {
	func write(to url: URL) throws {
		let jsonEncoder = JSONEncoder()
		jsonEncoder.outputFormatting = .prettyPrinted
		let data = try jsonEncoder.encode(self)
		try data.write(to: url)
	}
}
