// This source file is part of the Swift.org open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

import llbuild2
import LLBBuildSystem
import LLBBuildSystemProtocol
import NIO

/// Test implementation of a build engine context.
public class LLBTestBuildEngineContext: LLBBuildEngineContext {
    public let group: LLBFuturesDispatchGroup
    public let testDB: LLBTestCASDatabase
    public let testExecutor: LLBTestExecutor

    public var db: LLBCASDatabase { testDB }
    public var executor: LLBExecutor { testExecutor }

    public init(
        group: LLBFuturesDispatchGroup? = nil,
        db: LLBTestCASDatabase? = nil,
        executor: LLBTestExecutor? = nil
    ) {
        let group = group ?? MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.group = group
        self.testDB = db ?? LLBTestCASDatabase(group: group)
        self.testExecutor = executor ?? LLBTestExecutor(group: group)
    }
}

/// Test implementation of a build engine to be used for inspection during tests. This class is a wrapper around an
/// actual LLBBuildEngine.
public class LLBTestBuildEngine {
    public let engineContext: LLBTestBuildEngineContext
    private let engine: LLBBuildEngine

    public init(
        engineContext: LLBTestBuildEngineContext? = nil,
        buildFunctionLookupDelegate: LLBBuildFunctionLookupDelegate? = nil
    ) {
        let engineContext = engineContext ?? LLBTestBuildEngineContext()
        self.engineContext = engineContext

        self.engine = LLBBuildEngine(
            engineContext: engineContext,
            buildFunctionLookupDelegate: buildFunctionLookupDelegate
        )
    }

    public var group: LLBFuturesDispatchGroup { engineContext.group }
    public var db: LLBCASDatabase { engineContext.testDB }
    public var executor: LLBExecutor { engineContext.testExecutor }

    /// Requests the evaluation of a build key, returning an abstract build value.
    public func build(_ key: LLBBuildKey) -> LLBFuture<LLBBuildValue> {
        return self.engine.build(key)
    }

    /// Requests the evaluation of a build key and attempts to cast the resulting value to the specified type.
    public func build<V: LLBBuildValue>(_ key: LLBBuildKey, as valueType: V.Type = V.self) -> LLBFuture<V> {
        return self.engine.build(key)
    }
}
