import re
import sys


def mask_phone(phone):
    return phone[:3] + "****" + phone[-4:]


def mask_id(id_card):
    return id_card[:6] + "********" + id_card[-4:]


def mask_bank_card(card):
    return card[:4] + " **** **** " + card[-4:]


def mask_email(email):
    name, domain = email.split("@")
    return name[0] + "***@" + domain


def desensitize_text(text: str):

    text = re.sub(r'1[3-9]\d{9}',
                  lambda m: mask_phone(m.group()), text)

    text = re.sub(r'\d{17}[\dXx]',
                  lambda m: mask_id(m.group()), text)

    text = re.sub(r'\b\d{16,19}\b',
                  lambda m: mask_bank_card(m.group()), text)

    text = re.sub(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}',
                  lambda m: mask_email(m.group()), text)

    return text


# ⭐⭐⭐ CLI ENTRYPOINT（关键）
if __name__ == "__main__":
    input_text = sys.stdin.read()
    output = desensitize_text(input_text)
    print(output)