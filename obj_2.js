var target = {a: 1, b: 1};
var source1 = {b: 2, c: 2};
var source2 = {c: 3};
var source3 = {d: 4};

const result = Object.assign(target, source1, source2, source3);
console.log(result);

const result1 = Object.assign({b: 'c'},
  Object.defineProperty({}, 'invisible', {
    enumerable: true,
    value: 'hello'
  })
)

console.log(result1)
