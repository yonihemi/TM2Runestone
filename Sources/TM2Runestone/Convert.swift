import Foundation

/// Convert a `tmTheme` TextMate/SublimeText-style theme to a `Runestone` theme
public func convert(tmTheme tmThemeURL: URL, appearance: Appearance? = nil, toRunestonetheme output: URL) throws {
	let tmTheme = try TMTheme(contentsOf: tmThemeURL)
	let runestoneTheme = RunestoneTheme(
		tmTheme: tmTheme,
		appearance: appearance ?? tmTheme.estimateAppearance()
	)
	try runestoneTheme.write(to: output)
}

/// Convert a `tmTheme` TextMate/SublimeText-style theme to a `Runestone` theme
public func convert(tmTheme: TMTheme, appearance: Appearance? = nil, toRunestonetheme output: URL) throws {
	let runestoneTheme = RunestoneTheme(
		tmTheme: tmTheme,
		appearance: appearance ?? tmTheme.estimateAppearance()
	)
	try runestoneTheme.write(to: output)
}

extension RunestoneTheme {
	init(tmTheme: TMTheme, appearance: Appearance) {
		let foreground = tmTheme.globalSettings.foreground
		let background = tmTheme.globalSettings.background ?? "#FFFFFF"
		let editor = Editor(
			text: foreground,
			background: background,
			caret: tmTheme.globalSettings.caret.with(nilOrEmptyDefault: foreground),
			invisibleCharacters: tmTheme.globalSettings.invisibles.with(nilOrEmptyDefault: foreground),
			selectedLineBackground: tmTheme.globalSettings.lineHighlight.with(nilOrEmptyDefault: background),
			scrollIndicatorStyle: .default(for: appearance),
			gutter: Gutter(
				background: tmTheme.globalSettings.gutter.with(nilOrEmptyDefault: background),
				hairline: tmTheme.globalSettings.gutterForeground.with(nilOrEmptyDefault: foreground),
				lineNumber: tmTheme.globalSettings.gutterForeground.with(nilOrEmptyDefault: foreground),
				selectedLinesBackground: tmTheme.globalSettings.lineHighlight.with(nilOrEmptyDefault: background),
				selectedLinesLineNumber: tmTheme.globalSettings.gutterForeground.with(nilOrEmptyDefault: foreground)),
			pageGuide: PageGuide(
				background: tmTheme.globalSettings.activeguide.with(nilOrEmptyDefault: background),
				hairline: tmTheme.globalSettings.guide.with(nilOrEmptyDefault: foreground)
			))
		let scopes = tmTheme.scopeStyles.compactMap(Scope.init(tmScope:))
		self.init(editor: editor, scopes: scopes)
	}
}

extension Scope {
	/// Based on trial and error. *Not* an exhaiustive list.
	static let knownScopes = [
		"constant.numeric": "number",
		"storage.type": "type",
		"entity.name.function": "function",
		"punctuation.separator": "delimeter",
		"entity.name.tag": "tag",
		"entity.other.attribute-name": "attribute",
		"support.constant": "constant",
		"constant.character.escape": "escape",
		"markup.bold": "text.strong_emphasis",
		"markup.italic": "text.emphasis",
		"markup.heading": "text.title",
		"markup.underline.link": "text.link",
	]
	
	init?(tmScope: TMScopeStyle) {
		guard
			let foreground = tmScope.settings.foreground,
			!foreground.isEmpty else {
			return nil
		}
		let runestoneScope = Scope.knownScopes[tmScope.scope] ?? tmScope.scope
		self.init(
			name: runestoneScope,
			color: foreground,
			fontWeight: tmScope.settings.fontStyle?.bold == true ? .bold : .regular,
			fontStyle: tmScope.settings.fontStyle?.italic == true ? .italic : .regular
		)
	}
}

extension ScrollIndicatorStyle {
	static func `default`(for appearance: Appearance) -> ScrollIndicatorStyle {
		switch appearance {
		case .light:
			return .black
		case .dark:
			return .white
		}
	}
}

extension Optional where Wrapped == String {
	func with(nilOrEmptyDefault: String) -> String {
		if let self = self, !self.isEmpty { return self }
		return nilOrEmptyDefault
	}
}
