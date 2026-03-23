import type { Store, StoreData } from "../interfaces";
import dispatchDebugMessages from "./dispatchDebugMessages";

const storeTableTest: Store = {
    tools: {
      pendrive: {
        Item: "Pendrive",
        Price: 1000,
        Weight: 15
      },
      pickaxe: {
        Item: "Picareta",
        Price: 1000,
        Weight: 4
      },
      pliers: {
        Item: "Alicate",
        Price: 1000,
        Weight: 14
      },
      radio: {
        Item: "Radio",
        Price: 1000,
        Weight: 22
      },
      toolbox: {
        Item: "Caixa de ferramentas",
        Price: 1000,
        Weight: 11
      },
    },
    drinks: {
      absolut: {
        Item: "Vodka Absolut",
        Price: 1000,
        Weight: 12
      },
      acerolajuice: {
        Item: "Suco de acerola",
        Price: 1000,
        Weight: 17
      },
      beanmachine1: {
        Item: "Café expresso",
        Price: 1000,
        Weight: 22
      },
      milkbottle: {
        Item: "Garrafa de leite",
        Price: 1000,
        Weight: 28
      },
      milkshake: {
        Item: "Milkshake",
        Price: 1000,
        Weight: 36
      },
    },
    foods: {
      acerola: {
        Item: "Acerola",
        Price: 1000,
        Weight: 41
      },
      banana: {
        Item: "Banana",
        Price: 1000,
        Weight: 55
      },
      orange: {
        Item: "Laranja",
        Price: 1000,
        Weight: 2
      },
      chickenfries: {
        Item: "Galinha frita",
        Price: 1000,
        Weight: 1
      },
      onionrings: {
        Item: "Aneis de cebola",
        Price: 1000,
        Weight: 120
      },
    },
    eletronics: {
      acerola: {
        Item: "Acerola",
        Price: 1000,
        Weight: 41
      },
      banana: {
        Item: "Banana",
        Price: 1000,
        Weight: 55
      },
      orange: {
        Item: "Laranja",
        Price: 1000,
        Weight: 2
      },
      chickenfries: {
        Item: "Galinha frita",
        Price: 1000,
        Weight: 1
      },
      onionrings: {
        Item: "Aneis de cebola",
        Price: 1000,
        Weight: 120
      },
    },

    weapons: {
      acerola: {
        Item: "Acerola",
        Price: 1000,
        Weight: 41
      },
      banana: {
        Item: "Banana",
        Price: 1000,
        Weight: 55
      },
      orange: {
        Item: "Laranja",
        Price: 1000,
        Weight: 2
      },
      chickenfries: {
        Item: "Galinha frita",
        Price: 1000,
        Weight: 1
      },
      onionrings: {
        Item: "Aneis de cebola",
        Price: 1000,
        Weight: 120
      },
    },
  };

export function loadEvents(allow: boolean) {
    if (allow) {
        dispatchDebugMessages<StoreData>(
            [
              {
                action: "Open",
                data: {
                  Items: storeTableTest,
                  Illegal: true,
                  Mode: "Buy",
                  Type: "Department"
                },
              },
            ],
            1000
          );
    }
}
