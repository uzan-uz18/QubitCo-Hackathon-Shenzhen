export const shortenString = (
    str: string,
    startLength: number = 6,
    endLength: number = 6
): string => {
    if (str.length <= startLength + endLength + 3) {
        return str;
    }

    return `${str.slice(0, startLength)}...${str.slice(-endLength)}`;
};