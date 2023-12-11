// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract OwnableDelegateProxy {}

abstract contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}
