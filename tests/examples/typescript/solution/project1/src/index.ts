import { getGreeting } from './helper';

function sayHello(): void {
    const greeting = getGreeting();
    const name = "World";
    console.log(`${greeting}, ${name}!`);
}

sayHello();

