/**
 * @param eventName - The endpoint eventname to target
 * @param data - Data you wish to send in the NUI Callback
 *
 * @returns returnData - A promise for the data sent back by the NuiCallbacks CB argument
 */

export function fetchResponse<T = any>(
  eventName: string,
  data: unknown = {},
): Promise<T> {
  return new Promise<T>(async (resolve, reject) => {
    try {
      const options: RequestInit = {
        method: "POST",
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify(data),
      };

      const resourceName =
        typeof window !== "undefined" && (window as any).GetParentResourceName
          ? (window as any).GetParentResourceName()
          : "nui-frame-app";

      const url = `https://${resourceName}/${eventName}`;
      const response = await fetch(url, options);

      const responseData = (await response.json()) as T;
      resolve(responseData);
    } catch (error) {
      console.error("Fetch error:", error);
      reject(error);
    }
  });
}
