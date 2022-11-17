

# Payload Types

Sometimes you want to send data over that isn't just a primitive type, maybe you want to send over a custom class with some data inside of it. That is where payload types come into play.

A `PayloadType` is a concept that comes from [Binarize](https://pub.dev/packages/binarize) and it basically describes how to serialize and deserialize a type to binary and back.

## Defining a Payload Type

Let's define a payload type for the following class:

```dart
class MySimpleClass {
  MySimpleClass(this.aString, this.anInt, this.aDouble);

  final String aString;

  final int anInt;

  final double aDouble;
}
```

This class has three fields that we want to serialize in and from binary, to do that we can define a custom payload type:

```dart
import 'package:bolt/bolt.dart';

class _MySimpleClass extends PayloadType<MySimpleClass> {
  const _MySimpleClass();

  @override
  int length(MySimpleClass value) =>
      string16.length(value.aString) +
      int32.length(value.anInt) +
      float32.length(value.aDouble);

  @override
  MySimpleClass get(ByteData data, int offset) {
    var currentOffset = offset;

    final aString = string16.get(data, currentOffset);
    currentOffset += string16.length(aString);

    final anInt = int32.get(data, currentOffset);
    currentOffset += int32.length(anInt);

    final aDouble = float32.get(data, currentOffset);
    currentOffset += float32.length(aDouble);

    return MySimpleClass(aString, anInt, aDouble);
  }

  @override
  void set(MySimpleClass value, ByteData data, int offset) {
    var currentOffset = offset;

    string16.set(value.aString, data, currentOffset);
    currentOffset += string16.length(value.aString);

    int32.set(value.anInt, data, currentOffset);
    currentOffset += int32.length(value.anInt);

    float32.set(value.aDouble, data, currentOffset);
    currentOffset += float32.length(value.aDouble);
  }
}

const mySimpleClass = _MySimpleClass();
```

This custom payload type defines how the `MySimpleClass` should be serialized, by using the `mySimpleClass` constant we can now serialize any instance of the `MySimpleClass`.

You can now use this payload type whenever you [register a Data Object](data-objects.md#registering-a-data-object)