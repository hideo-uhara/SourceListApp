//
// SidebarViewController.swift
//

import Cocoa

class EmphasizedTableRowView: NSTableRowView {
	
	// 選択時の表示をグレー
	override var isEmphasized: Bool {
		get { return false }
		set {}
	}
}

class Location {
	var location: String
	
	init(location: String) {
		self.location = location
	}
}

class SidebarViewController: NSViewController {
	
	static let LocationsBar: String = "Locations"
	static let FavoritesBar: String = "Favorites"
	
	let sidebarRowPasteboardType: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: "private.sidebar-row") // 行の移動用

	
	let sidebar: [String] = [
		SidebarViewController.LocationsBar,
		SidebarViewController.FavoritesBar,
	]
	
	var sidebarItems: [String: [Location]] = [
		SidebarViewController.LocationsBar: [
			Location(location: "東京"),
			Location(location: "New York"),
			Location(location: "Hawaii"),
			Location(location: "Ayers Rock"),
		],
		
		SidebarViewController.FavoritesBar: [
			Location(location: "富士山"),
			Location(location: "Cape Hope"),
			Location(location: "鎌倉"),
			Location(location: "Egypt"),
			Location(location: "Everest"),
			Location(location: "Alps"),
			Location(location: "Machu Picchu"),
			Location(location: "Nile"),
			Location(location: "Niagara"),
		]
	]
	
	var draggingDestinationFeedbackStyleRegular: Bool = true
	var disableOutlineViewSelectionDidChange: Bool = false
	
	@IBOutlet var outlineView: NSOutlineView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.outlineView.registerForDraggedTypes([self.sidebarRowPasteboardType])
		
		for sidebar in self.sidebar {
			self.outlineView.expandItem(sidebar, expandChildren: false)
		}
	}

	override var representedObject: Any? {
		didSet {
		}
	}
	
	@IBAction func segmentedControlAction(_ sender: NSSegmentedControl) {
		
		switch sender.selectedSegment {
		case 0:
			self.draggingDestinationFeedbackStyleRegular = true
		case 1:
			self.draggingDestinationFeedbackStyleRegular = false
		default:
			break
		}
	}

}

extension SidebarViewController: NSOutlineViewDataSource {
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return self.sidebar.count
		} else {
			let item: String = item as! String
			
			return self.sidebarItems[item]!.count
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			return self.sidebar[index]
		} else {
			let item: String = item as! String
			
			return self.sidebarItems[item]![index]
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if item is String {
			return true
		} else {
			return false
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
		if self.draggingDestinationFeedbackStyleRegular {
			outlineView.draggingDestinationFeedbackStyle = .regular
		} else {
			outlineView.draggingDestinationFeedbackStyle = .gap
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
		outlineView.draggingDestinationFeedbackStyle = .none
	}
	
	func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
		let pasteboardItem: NSPasteboardItem = NSPasteboardItem()
		let index: Int = outlineView.row(forItem: item)
		
		pasteboardItem.setString(String(index), forType: self.sidebarRowPasteboardType)
		
		return pasteboardItem
	}
	
	func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
		let pasteboard: NSPasteboard = info.draggingPasteboard
		
		if info.draggingSource as? NSOutlineView == outlineView {
			if item == nil { // rootへの移動
				return []
			}
			if index == NSOutlineViewDropOnItemIndex { // アイテム上への移動(gapの場合この判定は無効、アイテム上に移動できない)
				return []
			}
			guard let draggingRow: Int = Int(pasteboard.string(forType: self.sidebarRowPasteboardType)!) else {
				return []
			}
			let draggingItem: Any = outlineView.item(atRow: draggingRow)!
			
			if draggingItem is String {
				return []
			}
			
			return .move
		}
		
		return []
	}
	
	func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
		let pasteboard: NSPasteboard = info.draggingPasteboard
		
		if info.draggingSource as? NSOutlineView == outlineView {
			guard let draggingRow: Int = Int(pasteboard.string(forType: self.sidebarRowPasteboardType)!) else {
				return false
			}
			
			let item: String = item as! String
			let draggingItem: Any = outlineView.item(atRow: draggingRow)!
			let draggingParent: String = outlineView.parent(forItem: draggingItem) as! String
			let draggingIndex: Int = outlineView.childIndex(forItem: draggingItem)
			var index: Int = index

			if item == draggingParent { // 同じ親への行の移動
				if draggingIndex < index {
					index -= 1
				}
			}
			
			let movedItem: Location = self.sidebarItems[draggingParent]![draggingIndex]
			
			self.sidebarItems[draggingParent]!.remove(at: draggingIndex)
			self.sidebarItems[item]!.insert(movedItem, at: index)
			
			if self.draggingDestinationFeedbackStyleRegular {
				outlineView.beginUpdates()
				outlineView.moveItem(at: draggingIndex, inParent: draggingParent, to: index, inParent: item)
				outlineView.endUpdates()
			} else {
				if item == draggingParent && index == draggingIndex { // 移動がない場合
					return true
				}
				
				let draggingRowSelected: Bool = outlineView.selectedRowIndexes.contains(draggingRow)
				
				if draggingRowSelected {
					self.disableOutlineViewSelectionDidChange = true
				}
				
				outlineView.beginUpdates()
				outlineView.removeItems(at: IndexSet(integer: draggingIndex), inParent: draggingParent)
				outlineView.insertItems(at: IndexSet(integer: index), inParent: item)
				outlineView.endUpdates()
				
				if draggingRowSelected {
					let row: Int = outlineView.row(forItem: draggingItem)
					
					if row != -1 {
						outlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
					}
					
					self.disableOutlineViewSelectionDidChange = false
				}
			}
			
			return true
		}
		
		return false
	}

}

extension SidebarViewController: NSOutlineViewDelegate {
	
	func outlineView(_ outlineView: NSOutlineView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
		
		var item: Any? = nil
		
		proposedSelectionIndexes.forEach { (index) in
			item = outlineView.item(atRow: index)
		}
		
		if item is String {
			if outlineView.selectedRowIndexes.isEmpty {
				return IndexSet()
			} else {
				return outlineView.selectedRowIndexes
			}
		} else {
			return proposedSelectionIndexes
		}
	}
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		if self.disableOutlineViewSelectionDidChange {
			return
		}
		
		if let outlineView: NSOutlineView = notification.object as? NSOutlineView {
			let selectionIndexes: IndexSet = outlineView.selectedRowIndexes
			
			selectionIndexes.forEach { (index) in
				let item: Location = outlineView.item(atRow: index) as! Location
				
				print(item.location)
			}
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		if item is String {
			return true
		} else {
			return false
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		
		if item is String {
			let cell: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("TableCellView"), owner: self) as! NSTableCellView
			let textField: NSTextField = cell.viewWithTag(1) as! NSTextField
			
			textField.stringValue = item as! String
			
			return cell
			
		} else {
			if let location: Location = item as? Location {
				let cell: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("TableCellView"), owner: self) as! NSTableCellView
				let textField: NSTextField = cell.viewWithTag(1) as! NSTextField
			
				textField.stringValue = location.location
			
				return cell

			} else {
				return nil
			}
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
		let identifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("TableRowView")
		
		var tableRowView: NSTableRowView? = outlineView.makeView(withIdentifier: identifier, owner: self) as? NSTableRowView
		
		if tableRowView == nil {
			tableRowView = EmphasizedTableRowView(frame: NSZeroRect)
			tableRowView?.identifier = identifier
		}
		
		return tableRowView
	}
	
}

