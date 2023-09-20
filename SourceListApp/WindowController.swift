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
	
	func toolbarWillAddItem(_ notification: Notification) {
		guard let userInfo = notification.userInfo else {
			return
		}
		
		if let toolbarItem: NSToolbarItem = userInfo["item"] as? NSToolbarItem {
			if toolbarItem.itemIdentifier == NSToolbarItem.Identifier.toggleSidebar {
				if #available(macOS 11.0, *) {
					toolbarItem.isNavigational = true
				}
			}
		}
	}
	
}

