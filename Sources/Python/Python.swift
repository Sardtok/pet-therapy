import AppKit
import Foundation
import Python
import PythonKit
import Schwifty
import SwiftUI

class PythonSetup {
    private let tag = "PythonSetup"
    
    private static var pets: PythonObject!
    
    static func run() {
        try? PythonSetup().setup()
    }
}

private extension PythonSetup {
    func setup() throws {
        try initialize()
        let sys = loadSys()
        try loadPets(sys: sys)
    }
    
    func initialize() throws {
        Logger.log(tag, "Initializing...")
        let stdLib = try stdLibPath()
        let libDynload = try libDynloadPath()
        setenv("PYTHONHOME", stdLib, 1)
        setenv("PYTHONPATH", "\(stdLib):\(libDynload)", 1)
        Py_Initialize()
    }
    
    func loadSys() -> PythonObject {
        Logger.log(tag, "Importing sys...")
        let sys = Python.import("sys")
        Logger.log(tag, "Version: \(sys.version_info.major).\(sys.version_info.minor)")
        return sys
    }
    
    func loadPets(sys: PythonObject) throws {
        Logger.log(tag, "Importing pets...")
        let path = try petsPath()
        sys.path.append(path)
        Logger.log(tag, "Pets Setup...")
        PythonSetup.pets = Python.import("pets")
    }
    
    func petsPath() throws -> String {
        let name = "pypets"
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else {
            throw PythonSetupError.missingPets
        }
        return path
    }
    
    func stdLibPath() throws -> String {
        let name = "python-stdlib"
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else {
            throw PythonSetupError.missingStdLib
        }
        return path
    }
    
    func libDynloadPath() throws -> String {
        let name = "python-stdlib/lib-dynload"
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else {
            throw PythonSetupError.missingLibDynload
        }
        return path
    }
    
    func petsAssetsPath() throws -> String {
        guard let path = Bundle.main.path(forResource: "PetsAssets", ofType: nil) else {
            throw PythonSetupError.missingAssets
        }
        return path
    }
}

enum PythonSetupError: Error {
    case missingStdLib
    case missingLibDynload
    case missingPets
    case missingAssets
    case missingSpecies
}
