export type StoreType = {
  [key: string]: { Item: string, Price: number, Weight: number, ImageIndex: string, Route: string };
};

export interface Store {
  [key: string]: StoreType;
};

export interface StoreData {
  Title: string;
  Items: Store
  Type: string;
  Illegal: boolean;
  Mode: string;
  Perm: string[];
}

export interface SelectedItem {
  [itemName: string]: { Amount: number, Item: string, Price: number, Weight: number, ImageIndex: string, Route: string };
}