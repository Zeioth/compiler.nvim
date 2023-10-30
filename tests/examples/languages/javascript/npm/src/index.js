import { getGreeting } from "./helper.js";
function sayHello() {
    const greeting = getGreeting();
    const name = "World";
    console.log(`${greeting}, ${name}!`);
}
sayHello();
