<script lang="ts">
  import { onDestroy, onMount } from "svelte";
  import type { SelectedItem, Store, StoreData } from "./interfaces";
  import { show } from "./store";
  import { fade } from "svelte/transition";
  import { fetchResponse } from "./lib/fetchResponse";
  import { addMessageListener } from "./lib/addMessageListener";
  import { loadEvents } from "./lib/loadEvents";

  let storeData: Store = {};
  let route: string = Object.keys(storeData)[0];
  let items;
  let squares = Array(35).fill(null);
  let selectedItems: SelectedItem = {};
  let totalValue: number = 0;
  let amountModal: Record<string, boolean> = {};
  let shopIllegal: boolean = false;
  let shopPerm: string[] = [];
  let shopType: string = "";
  let shopMode: string = "";
  let shopTitle: string = "";
  let tooltipData = {
    show: false,
    x: 0,
    y: 0,
    desc: "",
    peso: 0,
    qtd: 0,
    nome: ""
  };

  $: route = Object.keys(storeData)[0];

  function handleMouseEnter(event: MouseEvent, item: any) {
    const target = event.target as HTMLElement;
    const rect = target.getBoundingClientRect();
    
    tooltipData = {
      show: true,
      x: rect.left + rect.width - 30,
      y: rect.top - 110,
      desc: item[1].Description || "",
      peso: item[1].Weight || 0,
      qtd: item[1].Amount || 0,
      nome: item[1].Item || ""
    };
  }

  function handleMouseLeave() {
    tooltipData.show = false;
  }

  function selectItem(
    item: string,
    itemName: string,
    price: number,
    weight: number,
    imageIndex: string,
    route: string
  ) {
    if (selectedItems[item]) {
      totalValue -=
        selectedItems[item]["Price"] * selectedItems[item]["Amount"];
      delete selectedItems[item];
      selectedItems = selectedItems;
    } else {
      selectedItems[item] = {
        Item: itemName,
        Amount: 1,
        Price: price,
        Weight: weight,
        ImageIndex: imageIndex,
        Route: route // Armazena o ImageIndex aqui
      };
      totalValue += selectedItems[item]["Price"];
    }
  }
  
  function selectRoute(type: string) {
    route = type;
  }

  function changeAmount(item: string, type: string, amount: number) {
    if (selectedItems[item]) {
      const currentItem = selectedItems[item];
      if (type === "+" && amount > 0) {
        currentItem.Amount += amount;
      } else if (type === "-" && currentItem.Amount > 1) {
        currentItem.Amount -= amount;
      }

      totalValue = 0;
      for (const key in selectedItems) {
        totalValue += selectedItems[key].Amount * selectedItems[key].Price;
      }

      selectedItems[item] = currentItem;
    }
  }

  function clearVariables() {
    $show = false;
    amountModal = {};
    route = "";
    items = {};
    squares = Array(35).fill(null);
    selectedItems = {};
    totalValue = 0;
    storeData = {};
    shopIllegal = false;
    shopMode = "";
    shopType = "";
    shopTitle = "";
  }

  function finish() {
    fetchResponse("Finish", {
      Items: selectedItems,
      Mode: shopMode,
      Type: shopType,
      ListType: route,
    });
    clearVariables();
  }

  function close(event: KeyboardEvent) {
    if (event.key !==  "Escape") {
      return;
    }
    
    if (Object.keys(amountModal).length && $show) {
      amountModal = {};
    } else if ($show) {
      clearVariables();
      fetchResponse("Close", {});
    }
  }

  $: if (route && Object.keys(storeData).length > 0) {
    
    squares = Array(35).fill(null); // aqui onde limpa   
    items = Object.entries(storeData[route]);

    items.forEach((item, index) => {
        squares[index] = item;
    });
}


  addMessageListener("Open", (data: StoreData) => {
    $show = true;
    storeData = data.Items;
    shopType = data.Type;
    shopIllegal = data.Illegal;
    shopMode = data.Mode;
    shopTitle = data.Title;
    shopPerm = data.Perm || [];
  });

  onMount(() => {
    loadEvents(true)
    window.addEventListener("keydown", close);
  });

  onDestroy(() => {
    window.removeEventListener("keydown", close);
  });

function getStyleVariables() {
  const isIlegal = shopIllegal;
  const isPolice = shopPerm.includes("Police");
  // const isVenda = shopMode === "Sell";
  // const isEspecial = shopType === "vip" || shopType === "rare";

  let mainColor = "#f1406c";
  let textMainColor = "#fff";
  let textPriceColor = "#f1406c";
  let svgColor = "#fff";
  let hoverColor = "#f1406c";

  if (isIlegal) {
    mainColor = "#DADADA";
    textMainColor = "#171717";
    textPriceColor = "#fff";
    svgColor = "black";
    hoverColor = "rgba(0, 0, 0, 0.1)"
  }

  if (isPolice) {
    mainColor = "#374F6B";
    textMainColor = "#fff";
    textPriceColor = "#fff";
    svgColor = "#fff";
    hoverColor = "rgba(0, 0, 0, 0.1)"
  }

  // if (isVenda) {
  //   mainColor = "#40F1A0";
  //   textPriceColor = "#40F1A0";
  // }

  // if (isEspecial) {
  //   mainColor = "#FFD700";
  //   textMainColor = "#000";
  //   textPriceColor = "#FFD700";
  // }

  return `--mainColor: ${mainColor}; --textMainColor: ${textMainColor}; --textPriceColor: ${textPriceColor}; --svgColor: ${svgColor}; --hoverColor ${hoverColor}`;
}
</script>

{#if $show}
  <main
    out:fade = {{ duration: 150 }}
    style={getStyleVariables()}
  >
    <div
      class="stores"
      style="background: rgba(10, 10, 10, 0.9)"
    >
      <div class="stores__esc">
        <p>Pressione para sair da loja</p>
        <span>ESC</span>
      </div>

      <div class="stores__header">
        <h2>SELECIONE UMA DAS OPÇÕES ABAIXO</h2>

        <div>
          <div
            class="header__icon">
            <svg
              width="20"
              height="26"
              viewBox="0 0 20 26"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fill-rule="evenodd"
                clip-rule="evenodd"
                d="M3.81483 6.53232V7.04115H1.86072C1.57905 7.04096 1.30672 7.14785 1.0935 7.34228C0.880277 7.53671 0.740409 7.80569 0.699455 8.10007L0.41695 10.1533C-0.138983 14.1613 -0.138983 18.2335 0.41695 22.2415C0.538124 23.1143 0.931208 23.9196 1.53407 24.53C2.13693 25.1404 2.91519 25.5212 3.74583 25.6122L4.56471 25.7029C8.1787 26.099 11.8213 26.099 15.4353 25.7029L16.2555 25.6122C17.0859 25.5209 17.8639 25.14 18.4665 24.5296C19.0691 23.9192 19.462 23.1141 19.5831 22.2415C20.139 18.2335 20.139 14.1613 19.5831 10.1533L19.2993 8.10007C19.2583 7.80569 19.1184 7.53671 18.9052 7.34228C18.692 7.14785 18.4197 7.04096 18.138 7.04115H16.1826V6.53232C16.1826 4.79984 15.5311 3.13832 14.3714 1.91327C13.2117 0.688224 11.6388 0 9.99871 0C8.35864 0 6.78575 0.688224 5.62605 1.91327C4.46634 3.13832 3.81483 4.79984 3.81483 6.53232ZM11.0532 2.20449C10.4282 2.03457 9.77463 2.01795 9.14258 2.1559C8.51052 2.29385 7.91672 2.58272 7.40662 3.00039C6.89651 3.41807 6.48362 3.95348 6.19954 4.56566C5.91546 5.17783 5.76772 5.85055 5.76763 6.53232V7.04115H14.2298V6.53232C14.2297 5.54095 13.9175 4.57776 13.3425 3.7943C12.7674 3.01083 11.9621 2.45156 11.0532 2.20449ZM5.76763 9.10399C5.76763 8.83044 5.66476 8.56809 5.48165 8.37467C5.29854 8.18124 5.05019 8.07257 4.79123 8.07257C4.53227 8.07257 4.28392 8.18124 4.10081 8.37467C3.9177 8.56809 3.81483 8.83044 3.81483 9.10399V11.8544C3.81483 12.128 3.9177 12.3903 4.10081 12.5838C4.28392 12.7772 4.53227 12.8859 4.79123 12.8859C5.05019 12.8859 5.29854 12.7772 5.48165 12.5838C5.66476 12.3903 5.76763 12.128 5.76763 11.8544V9.10399ZM16.1826 9.10399C16.1826 8.83044 16.0797 8.56809 15.8966 8.37467C15.7135 8.18124 15.4651 8.07257 15.2062 8.07257C14.9472 8.07257 14.6989 8.18124 14.5158 8.37467C14.3327 8.56809 14.2298 8.83044 14.2298 9.10399V11.8544C14.2298 12.128 14.3327 12.3903 14.5158 12.5838C14.6989 12.7772 14.9472 12.8859 15.2062 12.8859C15.4651 12.8859 15.7135 12.7772 15.8966 12.5838C16.0797 12.3903 16.1826 12.128 16.1826 11.8544V9.10399Z"
                fill='var(--svgColor)'
              />
            </svg>
          </div>
          <p>{shopTitle?.trim() ? shopTitle : (!shopIllegal ? "Lojinha" : "Ilegal")}</p>
        </div>

      </div>

      <div class="stores__content">
        <div class="content__routes">
          {#if "tools" in storeData}
            <button 
              class="routes__tools" 
              class:selected={route === "tools"}
              on:click={() => selectRoute("tools")}
            >
              <svg width="28" height="28" viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M7.62991 0.321516C9.4448 -0.146131 11.3536 -0.102901 13.1455 0.446428C14.9374 0.995757 16.5425 2.0298 17.7835 3.4343C19.0246 4.83881 19.8532 6.55909 20.1779 8.40508C20.5026 10.2511 20.3107 12.1509 19.6235 13.8947L26.3012 19.5478C26.8077 19.9759 27.2198 20.5044 27.5115 21.0999C27.8032 21.6954 27.9681 22.345 27.9958 23.0076C28.0235 23.6701 27.9135 24.3312 27.6725 24.949C27.4316 25.5669 27.0651 26.1279 26.5962 26.5968C26.1273 27.0657 25.5662 27.4321 24.9484 27.6729C24.3305 27.9137 23.6695 28.0236 23.007 27.9958C22.3445 27.9679 21.695 27.8028 21.0996 27.511C20.5042 27.2191 19.9758 26.8069 19.5479 26.3003L13.8982 19.6248C12.1544 20.3133 10.2542 20.5061 8.40766 20.1818C6.56113 19.8576 4.84022 19.029 3.4352 17.7877C2.03017 16.5463 0.995759 14.9406 0.446334 13.148C-0.103091 11.3553 -0.146129 9.44569 0.321979 7.63013C0.387981 7.37502 0.521485 7.14242 0.708456 6.95676C0.895428 6.77109 1.12896 6.63924 1.3845 6.57505C1.64005 6.51086 1.90816 6.51671 2.16066 6.59198C2.41316 6.66725 2.64073 6.80917 2.81942 7.0028L7.24077 11.805L10.576 10.578L11.8059 7.23805L7.00119 2.82355C6.80641 2.64489 6.66353 2.41691 6.58765 2.16372C6.51178 1.91053 6.50573 1.64154 6.57014 1.38519C6.63456 1.12884 6.76705 0.894668 6.95359 0.707432C7.14014 0.520195 7.37382 0.386857 7.62991 0.321516Z"
                    fill={route === "tools"
                    ? 'var(--svgColor)'
                    : "#fff"}
                  fill-opacity={route === "tools" ? 1 : 0.1}
                />
                </svg>
            </button>
          {/if}
          
          {#if "drinks" in storeData}
            <button
              class="routes__drinks"
              class:selected={route === "drinks"}
              on:click={() => selectRoute("drinks")}
            >
              <svg
                width="26"
                height="50"
                viewBox="0 0 26 50"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M6.80623 50C5.60159 50 4.54115 49.6049 3.62491 48.8146C2.70868 48.0243 2.19072 47.0316 2.07104 45.8367L0.0168746 24.1524C-0.0321743 23.7974 0.0257035 23.4691 0.190508 23.1674C0.355312 22.8658 0.582897 22.5957 0.873267 22.3571C1.45401 21.8608 1.90035 21.2805 2.2123 20.6162C2.52425 19.9519 2.68121 19.2551 2.68317 18.5259C2.68317 17.8712 2.56545 17.2365 2.33002 16.6218C2.09851 16.0071 1.7483 15.4707 1.27939 15.0126C0.977252 14.774 0.760457 14.4781 0.629006 14.125C0.497555 13.7718 0.485783 13.4234 0.59369 13.0798L1.65903 8.81342C1.7689 8.29038 2.0475 7.86565 2.49483 7.53923C2.94215 7.2128 3.4503 7.04959 4.01927 7.04959H11.5856V2.86336H7.17115V0H18.9429V2.86336H14.5285V7.04959H22.0948C22.6559 7.04959 23.1474 7.20612 23.5692 7.51918C23.991 7.83224 24.2618 8.2627 24.3814 8.81056L25.4615 12.9682C25.5714 13.3118 25.5606 13.6601 25.4291 14.0133C25.2977 14.3664 25.0809 14.6623 24.7787 14.9009C24.3098 15.3495 23.9567 15.8783 23.7193 16.4872C23.4819 17.0962 23.3612 17.7261 23.3573 18.377C23.3573 19.1215 23.5113 19.8288 23.8193 20.4988C24.1274 21.1688 24.559 21.751 25.1142 22.2454C25.4026 22.486 25.6322 22.757 25.8029 23.0586C25.9736 23.3602 26.0334 23.6886 25.9824 24.0436L24.0401 45.7651C23.9223 46.9639 23.4083 47.9699 22.498 48.7831C21.5876 49.5963 20.5183 50.0019 19.2902 50H6.80623Z"
                  fill={route === "drinks"
                    ? "var(--svgColor)"
                    : "#fff"}
                  fill-opacity={route === "drinks" ? 1 : 0.1}
                />
              </svg>
              
            </button>
          {/if}
          
          {#if "foods" in storeData}
            <button 
              class="routes__foods" 
              class:selected={route === "foods"}
              on:click={() => selectRoute("foods")}
            >
              <svg width="28" height="28" viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M27.9403 5.05279C27.8787 4.78739 27.7669 4.53732 27.6113 4.31709C27.4558 4.09685 27.2596 3.91083 27.0341 3.76983C23.102 1.30368 18.5941 0 13.9985 0C9.4029 0 4.89492 1.30368 0.962826 3.76983C0.738031 3.91118 0.542323 4.09709 0.386898 4.31694C0.231474 4.53678 0.119384 4.78625 0.057041 5.05105C-0.00530184 5.31585 -0.0166737 5.5908 0.0235757 5.86017C0.0638251 6.12954 0.154906 6.38803 0.291607 6.62086L12.2911 27.0019C12.4693 27.3066 12.7203 27.5585 13.0198 27.7333C13.3193 27.9082 13.6573 28 14.001 28C14.3447 28 14.6826 27.9082 14.9821 27.7333C15.2816 27.5585 15.5326 27.3066 15.7109 27.0019L27.7103 6.62086C27.8472 6.38843 27.938 6.13005 27.9775 5.86082C28.017 5.59159 28.0044 5.3169 27.9403 5.05279ZM21.0532 13.9338C19.9417 13.4107 18.6841 13.3273 17.5174 13.6992C16.3508 14.0711 15.3556 14.8726 14.7195 15.9526C14.0834 17.0327 13.8504 18.3167 14.0643 19.5626C14.2783 20.8084 14.9244 21.9302 15.8809 22.7163L13.9985 25.9172L10.0612 19.2341C10.7076 18.9321 11.2846 18.491 11.7541 17.9401C12.2235 17.3892 12.5745 16.7411 12.7839 16.0388C12.9933 15.3364 13.0561 14.596 12.9684 13.8665C12.8806 13.1371 12.6443 12.4353 12.2749 11.8078C11.9056 11.1804 11.4118 10.6415 10.8262 10.227C10.2407 9.8125 9.57676 9.53188 8.8786 9.40374C8.18044 9.2756 7.46398 9.30288 6.77676 9.48377C6.08955 9.66466 5.4473 9.99501 4.89265 10.4529L4.09893 9.10386C7.08009 7.21716 10.5052 6.21897 13.9979 6.21897C17.4905 6.21897 20.9156 7.21716 23.8968 9.10386L21.0532 13.9338Z"
                  fill={route === "foods"
                  ? "var(--svgColor)"
                  : "#fff"}
                  fill-opacity={route === "foods" ? 1 : 0.1}
                />
              </svg>
            </button>
          {/if}

          {#if "eletronics" in storeData}
          <button 
            class="routes__eletronics" 
            class:selected={route === "eletronics"}
            on:click={() => selectRoute("eletronics")}
          >
            <svg width="20" height="40" viewBox="0 0 20 40" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M17.9076 13.0908H16.1868V11.7221C16.1868 11.3774 15.8465 11.0977 15.4252 11.0977H14.7778C14.3571 11.0977 14.0155 11.3774 14.0155 11.7221V13.0908H11.5641V10.6463C11.5641 10.1507 11.0745 9.74912 10.471 9.74912H9.54107C8.93708 9.74912 8.44802 10.1512 8.44802 10.6463V13.0908H4.90174C4.90174 13.0834 4.90487 13.077 4.90487 13.0693V7.80036C4.90487 7.3687 4.60058 6.99803 4.16228 6.8145V0.478364C4.16228 0.214104 3.89966 0 3.57795 0C3.25595 0 2.99489 0.214505 2.99489 0.478364V6.79123C2.52598 6.96577 2.19841 7.35064 2.19841 7.80036V13.0693C2.19841 13.077 2.20164 13.0834 2.20164 13.0908H2.09277C1.21295 13.0908 0.5 13.6759 0.5 14.3972V38.6945C0.5 39.4155 1.21295 40 2.09277 40H17.9076C18.787 40 19.5 39.4147 19.5 38.6945V14.3972C19.5001 13.6759 18.7871 13.0908 17.9076 13.0908ZM2.62213 16.3132C2.62213 15.5921 3.33508 15.007 4.21471 15.007H15.147C16.0269 15.007 16.7389 15.5921 16.7389 16.3132V20.0142C16.7389 20.7352 16.0269 21.3201 15.147 21.3201H4.21471C3.33508 21.3201 2.62213 20.7352 2.62213 20.0142V16.3132ZM9.9998 36.517C5.83751 36.517 2.4627 33.7492 2.4627 30.3337C2.4627 26.919 5.83751 24.1504 9.9998 24.1504C14.1621 24.1504 17.5358 26.919 17.5358 30.3337C17.5359 33.7492 14.1621 36.517 9.9998 36.517ZM9.9998 25.8493C6.98103 25.8493 4.5327 27.8574 4.5327 30.3341C4.5327 32.8111 6.98103 34.8199 9.9998 34.8199C13.0186 34.8199 15.467 32.8111 15.467 30.3341C15.467 27.8575 13.0186 25.8493 9.9998 25.8493ZM9.9998 32.4687C8.56314 32.4687 7.39742 31.5129 7.39742 30.3341C7.39742 29.1551 8.56314 28.1992 9.9998 28.1992C11.4362 28.1992 12.602 29.1551 12.602 30.3341C12.602 31.5131 11.4362 32.4687 9.9998 32.4687Z"
                fill={route === "eletronics"
                ? "var(--svgColor)"
                : "#fff"}
                fill-opacity={route === "eletronics" ? 1 : 0.1}
              />
            </svg>
          </button>
        {/if}

        {#if "weapons" in storeData}
        <button 
          class="routes__weapons" 
          class:selected={route === "weapons"}
          on:click={() => selectRoute("weapons")}
        >
          <svg width="36" height="36" viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M0.731179 30.7538C0.636781 30.6247 0.569137 30.4777 0.53227 30.3216C0.495402 30.1656 0.490063 30.0037 0.516572 29.8455C0.54308 29.6874 0.600894 29.5362 0.686575 29.401C0.772256 29.2658 0.884054 29.1493 1.01532 29.0586L8.50499 23.1875C7.88571 22.2848 8.61427 21.9766 8.61427 21.9766L8.00956 20.362C7.47042 19.2392 8.51956 18.1604 8.51956 18.1604L14.9528 13.3828C15.1656 13.2317 15.4064 13.1254 15.6608 13.0701C15.9153 13.0148 16.1782 13.0117 16.4339 13.061C16.6896 13.1104 16.9328 13.2111 17.149 13.3571C17.3652 13.5032 17.5499 13.6916 17.6922 13.9112L18.9891 13.1773C18.9172 13.0562 18.8699 12.9218 18.8501 12.7821C18.8302 12.6424 18.8381 12.5001 18.8734 12.3635C18.9086 12.2269 18.9705 12.0988 19.0554 11.9865C19.1403 11.8742 19.2466 11.7801 19.3679 11.7096L26.2456 6.22011V3.69556C26.3257 2.31586 27.047 2.88828 27.047 2.88828L29.342 5.16332C29.342 5.16332 34.3181 0.914139 34.6678 0.59857C35.0175 0.283 35.3308 0.826073 35.3308 0.826073C35.3308 0.826073 35.6223 1.171 35.4401 1.37649C35.258 1.58197 30.6607 5.77978 30.6607 5.77978L30.7919 6.90262L30.3766 7.36497L29.648 6.63109L28.4022 7.82732C28.4815 8.13251 28.4823 8.45303 28.4046 8.75863C28.3268 9.06423 28.173 9.34483 27.9577 9.57396L22.5663 15.2762C21.5828 16.1055 21.1092 15.5037 21.1092 15.5037L20.0163 16.6853C19.5574 17.3751 21.5828 19.1144 21.5828 19.1144L21.4006 19.6135C22.9913 21.2389 24.8438 22.5813 26.8794 23.5838L24.4606 27.3046C22.5689 26.5034 20.8622 25.3166 19.4481 23.8186L17.3862 24.9782C15.5502 26.3505 15.8854 27.2459 15.8854 27.2459L16.2278 29.7484C17.4664 30.3282 16.4537 30.8712 16.4537 30.8712L14.5375 31.7519C13.2698 32.5592 13.299 31.5391 13.299 31.5391L13.1387 26.6221C12.3664 24.8534 11.2153 25.7267 11.2153 25.7267C9.84099 26.9465 8.61787 28.3288 7.57242 29.8438L7.18628 34.1517C6.45772 36.2579 5.19001 35.2672 5.19001 35.2672L2.0426 32.0822L0.731179 30.7538Z"
                fill={route === "weapons"
                ? "var(--svgColor)"
                : "#fff"}
              fill-opacity={route === "weapons" ? 1 : 0.1} 
            />
          </svg>
        </button>
      {/if}
        </div>

        <div class="content__inventory">
          <p>ITENS DISPONÍVEIS</p>
          <div class="inventory__grid">
            {#each squares as square}
              {#if square}
                <button
                  class="inventory__item itemHover"
                  class:activeItem={selectedItems[square[0]]}
                  on:click={() =>
                    selectItem(
                      square[0],
                      square[1].Item,
                      square[1].Price,
                      square[1].Weight,
                      square[1].ImageIndex,
                      square[1].Route
                    )}
                  
                  
                  style="background-image: url(http://104.234.65.139/inventory/{square[1].ImageIndex}.png);"
                >
                  <div on:mouseenter={(e) => handleMouseEnter(e, square)}  on:mouseleave={handleMouseLeave}>
                    <svg  xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 13 13" fill="none">
                      <path d="M6.5 1.08333C9.48675 1.08333 11.9167 3.51325 11.9167 6.5C11.9167 9.48675 9.48675 11.9167 6.5 11.9167C3.51325 11.9167 1.08333 9.48675 1.08333 6.5C1.08333 3.51325 3.51325 1.08333 6.5 1.08333ZM6.5 0C2.91037 0 0 2.91037 0 6.5C0 10.0896 2.91037 13 6.5 13C10.0896 13 13 10.0896 13 6.5C13 2.91037 10.0896 0 6.5 0ZM5.39879 8.67208C5.70429 7.70304 6.28279 6.54225 6.38517 6.24867C6.53304 5.82238 6.27088 5.63333 5.44267 6.36188L5.2585 6.01521C6.20317 4.98767 8.14829 4.75529 7.48638 6.34725C7.07308 7.34121 6.77733 8.01233 6.60833 8.53017C6.36188 9.28471 6.98425 8.97867 7.59363 8.41588C7.6765 8.55129 7.70358 8.59517 7.78646 8.75117C6.43338 10.0393 4.93133 10.153 5.39879 8.67208ZM7.96738 4.24721C7.67921 4.49258 7.25238 4.48717 7.0135 4.23529C6.77463 3.98342 6.81471 3.58096 7.10233 3.33558C7.3905 3.09021 7.81733 3.09617 8.05621 3.3475C8.294 3.59992 8.255 4.00238 7.96738 4.24721Z" fill="currentColor"/>
                    </svg>
                  </div>
                  <div
                    class="inventory__item-price"
                    style={selectedItems[square[0]]
                      ? "display: flex; justify-content: center; align-items: center;"
                      : ""}
                  >
                    ${square[1].Price.toLocaleString("pt-BR")}
                  </div>
                </button>
              {:else}
                <button class="inventory__item"></button>
              {/if}
            {/each}
          </div>
        </div>

        <div class="content__cart">
          <p>SEU CARRINHO</p>

          <div class="cart__items">
            {#each Object.entries(selectedItems).reverse() as [key, index]}
              <div class="cart__item">
                <div class="cart__item-content">
                  <div class="cart__infos">
                    <div class="cart__item-image">
                      <img
                        src="http://104.234.65.139/inventory/{selectedItems[key]["ImageIndex"]}.png"
                        alt=""
                      />
                    </div>
                    <div class="cart__item-info">
                      <p>{index["Item"]}</p>
                      <span
                        >${index["Price"].toLocaleString("pt-BR")} | {index[
                          "Weight"
                        ]}kg</span
                      >
                    </div>
                  </div>

                  <div class="cart__actions">
                    <button
                      class="cart__item-add"
                      on:click={() => changeAmount(key, "+", 1)}>+</button
                    >
                    <button
                      class="cart__item-amount"
                      on:click={() => amountModal[key] = true}
                      >{selectedItems[key]["Amount"]}</button
                    >

                    {#if amountModal[key]}
                      <div class="modal">
                        <div class="amount-modal" out:fade = {{ duration: 150 }}>
                          <div class="amount-modal__info">
                            <div class="amount-modal__icon">
                              <svg
                                width="18"
                                height="18"
                                viewBox="0 0 18 18"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                              >
                                <path
                                  d="M9.028 14.23C9.24933 14.23 9.436 14.154 9.588 14.002C9.73933 13.8487 9.815 13.662 9.815 13.442C9.815 13.2207 9.73867 13.034 9.586 12.882C9.43333 12.73 9.24667 12.654 9.026 12.654C8.80467 12.654 8.618 12.7303 8.466 12.883C8.314 13.0357 8.238 13.2223 8.238 13.443C8.238 13.6643 8.31467 13.851 8.468 14.003C8.62 14.155 8.80667 14.231 9.028 14.231M9.003 18C7.759 18 6.589 17.764 5.493 17.292C4.39767 16.8193 3.44467 16.178 2.634 15.368C1.82333 14.5587 1.18167 13.6067 0.709 12.512C0.236333 11.4173 0 10.2477 0 9.00299C0 7.75899 0.236 6.58898 0.708 5.49298C1.18067 4.39765 1.822 3.44465 2.632 2.63398C3.44133 1.82332 4.39333 1.18165 5.488 0.708985C6.58267 0.236318 7.75233 -1.52588e-05 8.997 -1.52588e-05C10.241 -1.52588e-05 11.411 0.235985 12.507 0.707985C13.6023 1.18065 14.5553 1.82198 15.366 2.63198C16.1767 3.44132 16.8183 4.39332 17.291 5.48798C17.7637 6.58265 18 7.75232 18 8.99698C18 10.241 17.764 11.411 17.292 12.507C16.8193 13.6023 16.178 14.5553 15.368 15.366C14.5587 16.1767 13.6067 16.8183 12.512 17.291C11.4173 17.7637 10.2477 18 9.003 18ZM9 17C11.2333 17 13.125 16.225 14.675 14.675C16.225 13.125 17 11.2333 17 8.99998C17 6.76665 16.225 4.87498 14.675 3.32498C13.125 1.77498 11.2333 0.999985 9 0.999985C6.76667 0.999985 4.875 1.77498 3.325 3.32498C1.775 4.87498 1 6.76665 1 8.99998C1 11.2333 1.775 13.125 3.325 14.675C4.875 16.225 6.76667 17 9 17ZM9.062 4.73798C9.56867 4.73798 10.0047 4.89532 10.37 5.20998C10.7367 5.52398 10.92 5.91665 10.92 6.38798C10.92 6.75465 10.8167 7.08632 10.61 7.38299C10.4047 7.67899 10.1667 7.95198 9.896 8.20198C9.55333 8.51265 9.25167 8.85432 8.991 9.22698C8.73033 9.60032 8.58067 10.0113 8.542 10.46C8.52933 10.5907 8.57 10.6997 8.664 10.787C8.758 10.8743 8.868 10.9183 8.994 10.919C9.12867 10.919 9.242 10.8743 9.334 10.785C9.42533 10.695 9.48333 10.589 9.508 10.467C9.57467 10.1303 9.70867 9.83065 9.91 9.56798C10.1113 9.30598 10.332 9.05765 10.572 8.82298C10.9173 8.47965 11.2243 8.10499 11.493 7.69899C11.7617 7.29365 11.896 6.84132 11.896 6.34198C11.896 5.60732 11.6177 5.00132 11.061 4.52398C10.5037 4.04665 9.85 3.80798 9.1 3.80798C8.54333 3.80798 8.02567 3.93798 7.547 4.19798C7.06833 4.45798 6.68533 4.81798 6.398 5.27798C6.33267 5.38865 6.31167 5.50299 6.335 5.62099C6.35833 5.73899 6.42167 5.82832 6.525 5.88898C6.657 5.95898 6.79033 5.97565 6.925 5.93898C7.05967 5.90165 7.17833 5.82399 7.281 5.70599C7.50233 5.42999 7.76333 5.19998 8.064 5.01598C8.36467 4.83065 8.69733 4.73798 9.062 4.73798Z"
                                  fill="var(--svgColor)"
                                />
                              </svg>
                            </div>

                            <p>Quantidade</p>
                          </div>
                          <input
                            type="number"
                            placeholder="Digite a quantidade aqui"
                            bind:value={selectedItems[key]["Amount"]}
                            on:input={(event) => {
                              changeAmount(
                                key,
                                "keyboard",
                                selectedItems[key]["Amount"]
                              );
                              selectedItems[key]["Amount"] == null
                                ? changeAmount(
                                    key,
                                    "keyboard",
                                    (selectedItems[key]["Amount"] = 1)
                                  )
                                : selectedItems[key]["Amount"];
                            }}
                          />

                          <div class="amount-modal__buttons">
                            <button
                              on:click={() => {
                                selectedItems[key]["Amount"] =
                                  selectedItems[key]["Amount"] < 1
                                    ? 1
                                    : selectedItems[key]["Amount"];
                                changeAmount(
                                  key,
                                  "keyboard",
                                  selectedItems[key]["Amount"]
                                );
                                amountModal[key] = false;
                              }}>CONFIRMAR</button
                            >
                          </div>
                        </div>
                      </div>
                    {/if}
                    <button
                      class="cart__item-rem"
                      on:click={() => changeAmount(key, "-", 1)}>-</button
                    >
                  </div>
                </div>

                <button
                  class="cart__item-delete"
                  on:click={() => selectItem(key, index["Item"], 0, 0, index["ImageIndex"], index["Route"])}
                >
                  <svg
                    width="20"
                    height="24"
                    viewBox="0 0 20 24"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      fill-rule="evenodd"
                      clip-rule="evenodd"
                      d="M15 3.40338V3.66281C16.4433 3.79856 17.8808 3.99377 19.3089 4.24795C19.4167 4.26716 19.5198 4.30803 19.6123 4.36822C19.7048 4.42841 19.7848 4.50675 19.8478 4.59876C19.9109 4.69077 19.9557 4.79465 19.9797 4.90447C20.0037 5.01429 20.0064 5.1279 19.9878 5.23881C19.9691 5.34972 19.9294 5.45576 19.8708 5.55088C19.8123 5.646 19.7362 5.72833 19.6467 5.79317C19.5573 5.85801 19.4563 5.90409 19.3495 5.92879C19.2427 5.95349 19.1323 5.95631 19.0244 5.9371L18.7922 5.8971L17.6756 20.8343C17.6112 21.6955 17.2331 22.5 16.617 23.0869C16.0008 23.6739 15.192 24 14.3522 24H5.64889C4.80911 24 4.00029 23.6739 3.38415 23.0869C2.768 22.5 2.38995 21.6955 2.32556 20.8343L1.20778 5.8971L0.975562 5.9371C0.867733 5.95631 0.75728 5.95349 0.650511 5.92879C0.543742 5.90409 0.442747 5.85801 0.353293 5.79317C0.172633 5.66221 0.0499491 5.46281 0.0122295 5.23881C-0.0254902 5.01482 0.0248447 4.78458 0.152161 4.59876C0.279477 4.41294 0.473346 4.28675 0.691118 4.24795C2.11919 3.99346 3.55665 3.79826 5 3.66281V3.40338C5 1.61594 6.34778 0.0890836 8.12889 0.0307977C9.37635 -0.0102659 10.6248 -0.0102659 11.8722 0.0307977C13.6533 0.0890836 15 1.61594 15 3.40338ZM8.18223 1.74394C9.39414 1.70408 10.607 1.70408 11.8189 1.74394C12.6556 1.77137 13.3333 2.49595 13.3333 3.40338V3.53252C11.1132 3.39383 8.88685 3.39383 6.66667 3.53252V3.40338C6.66667 2.49595 7.34334 1.77137 8.18223 1.74394ZM7.78778 8.53825C7.78355 8.42568 7.7578 8.31508 7.71202 8.21276C7.66623 8.11043 7.60129 8.01838 7.52092 7.94186C7.44054 7.86535 7.34631 7.80586 7.24358 7.76681C7.14086 7.72775 7.03166 7.70989 6.92222 7.71425C6.81279 7.7186 6.70526 7.74508 6.60578 7.79217C6.50629 7.83927 6.4168 7.90606 6.34241 7.98873C6.26802 8.0714 6.21019 8.16833 6.17222 8.27399C6.13425 8.37965 6.11688 8.49197 6.12111 8.60453L6.50667 18.8903C6.51522 19.1174 6.61115 19.3318 6.77337 19.4863C6.85369 19.5627 6.94787 19.6222 7.05053 19.6612C7.15318 19.7002 7.26231 19.7181 7.37167 19.7137C7.48103 19.7094 7.58849 19.6829 7.68791 19.6358C7.78733 19.5888 7.87676 19.522 7.9511 19.4394C8.02543 19.3568 8.08322 19.2599 8.12116 19.1543C8.15911 19.0487 8.17646 18.9365 8.17222 18.824L7.78778 8.53825ZM13.8767 8.60453C13.8848 8.48981 13.8704 8.37457 13.8344 8.26569C13.7983 8.1568 13.7413 8.0565 13.6667 7.97075C13.5922 7.885 13.5016 7.81556 13.4005 7.76657C13.2993 7.71758 13.1895 7.69004 13.0778 7.68559C12.966 7.68114 12.8546 7.69987 12.75 7.74067C12.6454 7.78147 12.5499 7.84349 12.4692 7.92306C12.3884 8.00262 12.324 8.09809 12.2799 8.20378C12.2357 8.30947 12.2127 8.42322 12.2122 8.53825L11.8267 18.824C11.8181 19.0513 11.8977 19.2728 12.048 19.4398C12.1982 19.6068 12.4068 19.7055 12.6278 19.7143C12.8488 19.7231 13.0641 19.6412 13.2265 19.4867C13.3888 19.3321 13.4848 19.1176 13.4933 18.8903L13.8767 8.60453Z"
                      fill="white"
                      fill-opacity="0.1"
                    />
                  </svg>
                </button>
              </div>
            {/each}
          </div>

          <div class="cart__price">
            <p>VALOR TOTAL</p>
            <h2>$ {totalValue.toLocaleString("pt-BR")}</h2>
          </div>

          <button
            class="cart__finish"
            disabled={!selectedItems || totalValue == 0}
            style="opacity: {!selectedItems || totalValue == 0
              ? 0.5
              : 1}; cursor: {!selectedItems || totalValue == 0
              ? 'default'
              : 'pointer'};"
            on:click={finish}
            >FINALIZAR {shopMode == "Buy" ? "COMPRA" : "VENDA"}</button
          >
        </div>
      </div>
    </div>

    {#if tooltipData.show}
      <div 
        class="detalhes_box"
        style="left: {tooltipData.x}px; top: {tooltipData.y}px;"
        transition:fade={{ duration: 100 }}
      >
        <div class="top_desc">
          <span>{tooltipData.nome}</span>
        </div>
        <div class="bottom_desc">
          <span>PESO: <span>{tooltipData.peso.toFixed(2)}</span></span>
        </div>
      </div>
    {/if}

    <!-- <div
      class="main-blur"
      style="top: 0; right: 0; background: {!shopIllegal
        ? '#f1406c38'
        : '#FFFFFF38'};"
    ></div>
    <div
      class="main-blur"
      style="bottom: 0; right: 0; background: {!shopIllegal
        ? '#f1406c38'
        : '#FFFFFF38'};"
    ></div>
    <div
      class="main-blur"
      style="top: 0; left: 0; background: {!shopIllegal
        ? '#f1406c38'
        : '#FFFFFF38'};"
    ></div>
    <div
      class="main-blur"
      style="bottom: 16.77083vw; left: 19.375vw; background: {!shopIllegal
        ? '#f1406c38'
        : '#FFFFFF38'};"
    ></div> -->
  </main>
{/if}

<style lang="scss">
  @mixin flex-center {
    display: flex;
    justify-content: center;
    align-items: center;
  }

  main {
    width: 100vw;
    height: 100vh;

    @include flex-center();
  }

  .stores {
    width: 100%;
    height: 100%;
    position: relative;
    padding: 5.72917vw 0 0 0;

    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    align-items: center;
    gap: 2.08333vw;

    &__esc {
      display: flex;
      align-items: center;
      gap: 1.04167vw;

      position: absolute;
      top: 4.16667vw;
      right: 4.16667vw;

      p {
        font-size: 1.04167vw;
        font-weight: 400;
        color: #ffffff80;
        white-space: nowrap;
      }

      span {
        padding: 0.41667vw 0.83333vw;
        width: 3.64583vw;
        height: 2.08333vw;
        background: var(--mainColor);
        border: 0.05208vw #ffffff0f;
        border-top-style: inset;
        border-bottom-style: outset;
        border-left-style: inset;
        border-right-style: outset;
        border-radius: 0.20833vw;

        @include flex-center();

        font-size: 0.9375vw;
        font-weight: 700;
        color: var(--textMainColor);
      }
    }
  }

  .stores__header {
    position: relative;
    left: -116px;
    /* transform: translateX(50%); */
    display: flex;

    flex-direction: column;
    justify-content: start;
    align-items: start;
    width: 700px;
    
    /* width: 540px; */
    
    div {
      @include flex-center();
      gap: 1.04167vw;
    }

    h2 {
      font-size: 18px;
      color: rgba(255, 255, 255, 0.2);
      letter-spacing: 3px !important;
      font-weight: 500;
      margin-bottom: 21px;
    }

    p {
      font-size: 42px;
      color: #FFFFFF;
      /* letter-spacing: 0.16px; */
      font-weight: 800;
    }
  }

  .header__icon {
    @include flex-center();

    min-width: 50px;
    min-height: 50px;

    background: var(--mainColor);
    border-radius: 6px;

    svg {
      width: 1.04167vw;
      height: 1.35417vw;
    }
  }

  .stores__content {
    display: flex;
    align-items: center;
    /* width: 1273px; */
    gap: 2.86458vw;
  }

  .content__routes {
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    gap: 14px !important;
  }

  .routes__tools,
  .routes__drinks,
  .routes__foods,
  .routes__eletronics,
  .routes__weapons {
    @include flex-center();

    background: rgba(255, 255, 255, 0.02);
    border: 1px solid rgba(255, 255, 255, 0.04);
    border-radius: 6px;
    height: 60px !important;
    width: 60px !important;
    cursor: pointer;
    display: flex;
    justify-content: center;
    align-items: center;

    &.selected {
      background: var(--mainColor);
      border: 1px solid rgba(130, 0, 33, 0.2);
    }
  }

  /* .routes__tools,
  .routes__foods {
    width: 2.60417vw;
    height: 2.60417vw;

    svg {
      width: 1.875vw;
      height: 1.875vw;
    }
  }

  .routes__eletronics,
  .routes__weapons {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 2.604vw;
    height: 2.604vw;
    margin-left: 0.26vw;

    svg {
      width: 2.604vw;
      height: 2.604vw;
    }
  }

  .routes__drinks {
    width: 2.60417vw;
    height: 2.60417vw;

    svg {
      width: 1.35417vw;
      height: 2.60417vw;
    }
  } */

  .content__inventory {
    height: 100%;
    display: flex;
    flex-direction: column;
    gap: 0.88542vw;
    margin-right: 20px;

    p {
      font-size: 18px;
      font-weight: 600;
      color: rgba(255, 255, 255, 0.2);
    }
  }

  .inventory__grid {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    grid-template-rows: repeat(5, 1fr);
    max-height: 660px;
    /* max-height: 660px; */
    width: 550px;
    grid-gap: 10px;
    overflow-y: auto;
    overflow-x: hidden;
    padding-right: 15px !important;
    /* margin-right: 20px !important; */
    width: fit-content;

    /* padding-right: 0.3125vw; */
    filter: none;
  }

  .inventory__item {
    @include flex-center();
    position: relative;
    width: 100px;
    height: 100px;
    border-radius: 0.5rem;
    background: rgba(255, 255, 255, 0.02);
    border: 1px solid rgba(255, 255, 255, 0.04);
    overflow: hidden;

    &:focus {
      outline: transparent;
    }

    svg {
      position: absolute;
      top: 4px;
      left: 4px;
      color: white;
    }

    &:hover {
      svg {
        color: var(--mainColor);
      }
    }

    background-size: 70% !important;
    background-position: center;
    background-repeat: no-repeat;
  }

  .inventory__item-price {
    font-family: 'Sora';
    display: none;
    position: absolute;
    bottom: 0;
    /* right: 0; */
    width: 100%;
    height: 17px;
    background: var(--mainColor);
    font-size: 12px;
    font-weight: 600;
    color: var(--textMainColor);
  }

  .content__cart {
    width: 413px;
    height: 577px;
    display: flex;
    flex-direction: column;

    p {
      font-size: 18px;
      font-weight: 500;
      color: rgba(255, 255, 255, 0.2);
    }
  }

  .cart__items {
    width: 100%;
    height: 380px;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    gap: 10px;
    padding-right: 20px;
    box-sizing: content-box;
    width: fit-content;
    margin-top: 25px;

    /* direction: rtl; */
    /* padding-left: 0.3125vw; */
  }

  .cart__item {
    /* direction: ltr; */
    /* width: 100%; */
    /* height: 4.16667vw; */

    width: 453px !important;
    height: 80px;


    display: flex;
    align-items: center;
    gap: 1.04167vw;
  }

  .cart__item-content {
    width: 100%;
    height: 80px;

    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1.04167vw;
    padding: 0.78125vw 1.45833vw;
    background: #ffffff05;
    border: 0.05208vw #ffffff0a;
    border-top-style: inset;
    border-bottom-style: outset;
    border-left-style: inset;
    border-right-style: outset;
    border-radius: 0.3125vw;

  }

  .cart__infos {
    display: flex;
    align-items: center;
    gap: 1.30208vw;
  }

  .cart__item-image {
    @include flex-center();

    width: 2.60417vw;
    height: 2.60417vw;

    img {
      width: 2.60417vw;
      height: 2.60417vw;
    }
  }

  .cart__item-info {
    display: flex;
    flex-direction: column;
    gap: 0.26042vw;

    p {
      font-size: 14px;
      font-weight: 700;
      color: #ffffff;
      white-space: nowrap;
      text-transform: uppercase;
    }

    span {
      font-size: 0.72917vw;
      font-weight: 400;
      color: #ffffff4d;
      white-space: nowrap;
    }
  }

  .cart__actions {
    display: flex;
    align-items: center;
    gap: 0.83333vw;
  }

  .cart__item-add,
  .cart__item-rem {
    @include flex-center();

    min-width: 1.66667vw;
    height: 1.66667vw;
    background: var(--mainColor);
    padding: 0.52083vw;
    border: transparent;
    border-radius: 0.10417vw;

    font-size: 1.14583vw;
    font-weight: 500;
    color: var(--textMainColor);
    cursor: pointer;

    &:focus {
      outline: transparent;
    }
  }

  .cart__item-amount {
    @include flex-center();
    font-weight: 700;
    color: #fff;
    font-size: 1.14583vw;
    background: transparent;
    border: transparent;

    &:hover {
      cursor: pointer;
    }

    &:focus {
      outline: transparent;
    }
  }

  .cart__item-delete {
    @include flex-center();

    width: 1.04167vw;
    height: 1.25vw;

    border: transparent;
    background: transparent;
    cursor: pointer;

    &:focus {
      outline: transparent;
    }

    &:hover {
      path {
        transition: 0.2s all;
        fill-opacity: 1;
      }
    }

    svg {
      width: 1.04167vw;
      height: 1.25vw;
    }
  }

  .cart__price {
    display: flex;
    /* flex-direction: column; */
    align-items: center;
    justify-content: space-between;
    background: rgba(255, 255, 255, 0.02);
    border-radius: 4px;
    border: 1px solid rgba(255, 255, 255, 0.04);
    height: 56px;
    padding: 0px 24px 0px 26px;
    margin-top: 38px;

    p {
      font-size: 14px;
      font-weight: 600;
      color: rgba(255, 255, 255, 0.2);
    }

    h2 {
      font-size: 20px;
      font-weight: 700;
      color: #fff;

      /* s { */
        text-decoration: none;
        /* color: var(--textPriceColor); */
      /* } */
    }
  }

  .cart__finish {
    @include flex-center();

    min-width: 100%;
    min-height: 3.02083vw;

    font-size: 18px;
    font-weight: 800;
    color: var(--textMainColor);

    background: var(--mainColor);
    border: transparent;
    border-radius: 6px;
    margin-top: 32px;

    &:focus {
      outline: transparent;
    }
  }

  .activeItem {
    /* border: 0.05208vw var(--mainColor);
    border-top-style: inset;
    border-bottom-style: outset;
    border-left-style: inset;
    border-right-style: outset; */
    background-color: var(--hoverColor);
  }

  .itemHover:hover {
    cursor: pointer;
    border: 0.05208vw var(--mainColor);
    border-top-style: inset;
    border-bottom-style: outset;
    border-left-style: inset;
    border-right-style: outset;
    background-color: var(--hoverColor);

    svg {
      fill: var(--mainColor) !important;
    }

    .inventory__item-price {
      @include flex-center();
    }
  }

  .modal {
    @include flex-center();

    position: absolute;
    left: 0;
    top: 0;
    z-index: 99999;
    width: 100%;
    height: 100%;

    background: rgba(0, 0, 0, 0.5);
  }

  .amount-modal {
    opacity: 1;
    width: 15.625vw;

    background: #ffffff05;
    border: 0.05208vw #ffffff0a;
    border-top-style: inset;
    border-bottom-style: outset;
    border-left-style: inset;
    border-right-style: outset;
    border-radius: 0.3125vw;
    padding: 0.83333vw;

    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: flex-start;
    gap: 0.83333vw;

    &__icon {
      width: 0.9375vw;
      height: 0.9375vw;

      @include flex-center();
    }

    &__info {
      width: 100%;
      display: flex;
      align-items: center;
      gap: 0.83333vw;
    }

    &__buttons {
      width: 100%;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 0.625vw;

      button {
        @include flex-center();
        width: 100%;
        height: 2.08333vw;
        padding: 0.41667vw;
        transition: 0.2s all;
        background: #ffffff05;
        border: 0.05208vw #ffffff0a;
        border-top-style: inset;
        border-bottom-style: outset;
        border-left-style: inset;
        border-right-style: outset;
        border-radius: 0.3125vw;
        font-size: 0.83333vw;
        font-weight: 500;
        color: #ffffff6d;
        cursor: pointer;

        &:hover {
          background: var(--mainColor);
          color: var(--textMainColor);
        }
      }
    }

    input {
      width: 100%;
      height: 2.08333vw;
      background: #ffffff05;
      border: 0.05208vw #ffffff0a;
      border-top-style: inset;
      border-bottom-style: outset;
      border-left-style: inset;
      border-right-style: outset;
      border-radius: 0.3125vw;

      font-size: 0.9375vw;
      font-weight: 500;
      color: #ffffff;
      padding: 0.41667vw;
      display: flex;
      justify-content: center;
      align-items: center;

      &:focus {
        outline: transparent;
      }

      &::placeholder {
        font-size: 0.9375vw;
        font-weight: 500;
        color: #ffffff6d;
      }
    }

    p {
      font-size: 1.14583vw;
      font-weight: 600;
      color: #ffffffcc;
    }
  }

  .main-blur {
    pointer-events: none;
    position: absolute;
    width: 15.625vw;
    height: 15.625vw;
    flex-shrink: 0;
    border-radius: 15.625vw;
    mix-blend-mode: screen;
    filter: blur(11.12566vw);
  }

  .detalhes_box {
    position: absolute;
    width: auto;
    min-width: 10rem;
    /* min-width: fit-content; */
    min-height: 2rem;
    border-radius: 0.5rem;
    border: 1px solid rgba(255, 255, 255, 0.1);
    background: rgba(31, 31, 31, 0.9);
    padding: .6rem;
    z-index: 500;
      .top_desc {
        display: flex;
        align-items: center;
        justify-content: space-between;
        width: 100%;
        color: #fff;
        font-size: 14px;
        font-weight: 600;
      }
    
      .bottom_desc {
        white-space: nowrap;
        flex-wrap: wrap;
        width: 100%;
        margin-top: 5px;
        span {
          color: white;
          font-size: 12px;
          font-weight: 600;
          span {
            color: rgba(255, 255, 255, 0.6) !important;
          }
        }
      }

  }




  /* ::-webkit-scrollbar { width: 0.3125vw; }
  ::-webkit-scrollbar-track { background: #FFFFFF05;	border-radius: 0.3125vw; }
  ::-webkit-scrollbar-thumb { background: var(--mainColor); border-radius: 0.3125vw; }
  ::-webkit-scrollbar-thumb:hover { background: var(--mainColor); border-radius: 0.3125vw; } */

  *::-webkit-scrollbar {
    width: 4px;
}

@media (max-width: 1400px) {
	.stores{
			zoom: 0.75;
	}
}

*::-webkit-scrollbar-thumb {
    width: 4px;
    border-radius: 6px;
    background: #FFFFFF;
}

*::-webkit-scrollbar-track {
    width: 4px;
    border-radius: 6px;
    background: rgba(255, 255, 255, 0.02);
  }
  input::-webkit-outer-spin-button,
  input::-webkit-inner-spin-button { -webkit-appearance: none; }


</style>
