//
// WindowController.swift
//

import Cocoa

class WindowController: NSWindowController {
	
	override func windowDidLoad() {
		super.windowDidLoad()
	}
}

extension WindowController: NSToolbarDelegate {
	
	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		var items: [NSToolbarItem.Identifier] = []
		
		if #available(macOS 11.0, *) {
			items.append(NSToolbarItem.Identifier.flexibleSpace)
			items.append(NSToolbarItem.Identifier("DraggingDestinationFeedbackStyle"))
			items.append(NSToolbarItem.Identifier.sidebarTrackingSeparator)
			items.append(NSToolbarItem.Identifier.toggleSidebar)
		} else {
			items.append(NSToolbarItem.Identifier.toggleSidebar)
			items.append(NSToolbarItem.Identifier("DraggingDestinationFeedbackStyle"))
		}
		
		return items
	}
}

