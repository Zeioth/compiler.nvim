import { getGreeting } from './helper';

function sayHello(): void {
    const greeting = getGreeting();
    const name = "World2";
    console.log(`${greeting}, ${name}!`);
}

sayHello();

