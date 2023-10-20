import { getGreeting } from "./helper.js";


function sayHello(): void {
    const greeting = getGreeting();
    const name = "World";
    console.log(`${greeting}, ${name}!`);
}

sayHello();
