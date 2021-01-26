CMakeJSON layouts are in the form:

<member|index>;[<member|index]:type[;<allowed_values>];[<member|index>;jsontype;....] [;OPTIONAL]

type can be any valid JSON type (NUMBER, STRING, BOOLEAN, ARRAY, or OBJECT; except for NULL) and additionally ENUM.
ENUM is STRING base type with the values allowed in [:<allowed_values>] otherwise specifying [;<allowed_values>] is disallowed