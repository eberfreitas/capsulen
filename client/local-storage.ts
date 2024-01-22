export function set(key: string, value: unknown): void {
  const valueToPersist = JSON.stringify(value);

  window.localStorage.setItem(key, valueToPersist);
}

export function get(key: string): unknown {
  try {
    const value = window.localStorage.getItem(key);

    if (value) return JSON.parse(value);

    return null;
  } catch (_) {
    return null;
  }
}
