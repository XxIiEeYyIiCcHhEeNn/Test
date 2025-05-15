import time
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

def configure_chrome_options():
    options = Options()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=1920,1080")
    options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
    return options

def fetch_product_info(driver, url):
    driver.get(url)
    WebDriverWait(driver, 30).until(EC.presence_of_element_located((By.TAG_NAME, "body")))
    time.sleep(5)
    return driver.title

def find_seller_info(driver):
    seller_elements = driver.find_elements(By.XPATH, "//*[contains(text(), 'Sold by')]")
    for elem in seller_elements:
        if 'Sold by' in elem.text:
            return elem.text.replace('Sold by', '').strip()
    return None

def get_tiktok_product_info(url):
    product_info = {}
    try:
        chrome_options = configure_chrome_options()
        with webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options) as driver:
            product_info['商品标题'] = fetch_product_info(driver, url)
            seller_info = find_seller_info(driver)
            if seller_info:
                product_info['卖家'] = seller_info
    except Exception as e:
        print(f"发生错误: {str(e)}")
        return {'错误': f"获取商品信息时出错: {str(e)}"}
    return product_info

if __name__ == "__main__":
    product_url = "https://shop.tiktok.com/view/product/1730865066808414705?region=US&locale=en&source=seller_center"
    product_data = get_tiktok_product_info(product_url)
    for key, value in product_data.items():
        print(f"{key}: {value}")
