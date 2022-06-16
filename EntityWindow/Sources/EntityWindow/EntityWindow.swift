//
// Pet Therapy.
//

import AppKit
import Combine
import Physics
import SwiftUI

open class EntityWindow: NSWindow {
    
    public let entity: PhysicsEntity
    public let habitat: HabitatViewModel
    
    public weak var entityView: NSView!
    
    private var boundsCanc: AnyCancellable!
    private var aliveCanc: AnyCancellable!
    
    public init(representing entity: PhysicsEntity, in habitat: HabitatViewModel) {
        self.entity = entity
        self.habitat = habitat
        
        super.init(
            contentRect: .zero,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        makeTransparent()
        loadEntityView()
        bindToEntityFrame()
        bindToEntityLifecycle()
    }
    
    private func loadEntityView() {
        let view = HostedEntityView(representing: entity, in: habitat)
        setFrame(CGRect(size: view.frame.size), display: true)
        contentView?.addSubview(view)
        view.constrainToFillParent()
        entityView = view
    }
    
    private func makeTransparent() {
        isOpaque = false
        hasShadow = false
        backgroundColor = .clear
        isMovableByWindowBackground = true
        level = .statusBar
        collectionBehavior = .canJoinAllSpaces
    }
    
    open override func close() {
        boundsCanc?.cancel()
        boundsCanc = nil
        super.close()
    }
}

// MARK: - Frame

private extension EntityWindow {
    
    func bindToEntityFrame() {
        boundsCanc = entity.$frame.sink { frame in
            self.updateFrame(
                toShow: frame,
                in: self.habitat.state.bounds
            )
        }
    }
    
    func updateFrame(toShow entityFrame: CGRect, in habitat: CGRect) {
        let newOrigin = CGPoint(
            x: entityFrame.minX,
            y: habitat.height - entityFrame.maxY
        )
        
        if frame.size == entityFrame.size {
            if newOrigin != frame.origin {
                setFrameOrigin(newOrigin)
            }
        } else {
            setFrame(
                CGRect(origin: newOrigin, size: entityFrame.size),
                display: true
            )
        }
    }
}

// MARK: - Alive

extension EntityWindow {
    
    func bindToEntityLifecycle() {
        aliveCanc = entity.$isAlive.sink { isAlive in
            if !isAlive {
                self.close()
            }
        }
    }
}
