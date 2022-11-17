# Bolt Protocol

The Bolt Protocol is what powers both the `BoltServer` and the `BoltClient`. It handles setting up connections between server and client, automatically serialize and deserializes `DataObject`s, protects against data and IP manipulation and few other things.

This document tries to describe how the protocol works at the lowest level.

The Bolt Protocol would never have existed without detailed articles and documentation from:
- [Glenn Fiedler](https://gafferongames.com/)
- [Unreal Networking Architecture](https://docs.unrealengine.com/udk/Three/NetworkingOverview.html)

## Bindings

By default Bolt does not know about what kind of underlying communication protocol you are using to transfer data, instead it expects that you, the developer, provide implementations of the `BoltBinding` class to both the `BoltServer` and the `BoltClient`.

This allows Bolt to run on top of any communication protocol like UDP, TCP, WebSockets and whatever else allows for bi-directional communication. 

These bindings allow Bolt to be structured in such a way that a `BoltServer` can receive an `n` amount of bindings and communicate with any client that connects with a corresponding binding. In short this means that if a `BoltServer` has both a UDP and WebSockets binding attached to it, it can receive data from a `BoltClient` that uses UDP and a `BoltClient` that uses WebSockets without needing any further setup from the developer.

## Connection between Client and Server

TODO(wolfen): describe this in detail with graphs

## Serialization

TODO(wolfen): describe this in detail

## Acknowledgments

Whenever a Data Object is sent over the line, Bolt will associate an `sequence` identifier to it. When the other side receives that Data Object it will register it's `sequence` as a received packet. That registered `sequence` is then used whenever the receiving end emits it's own Data Objects. 

Bolt will automatically add the last received `sequence` as an `last_acknowledged` value to the header of the packet and on top of that it will add a 32bit integer where each bit represents a previous acknowledged `sequence`. This means that if the `n`th bit of the integer is set to true, than the `last_acknowledged` - `n` sequence was also acknowledged by the other side.

