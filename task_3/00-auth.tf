terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.27.0"
    }
     random = {
      source = "hashicorp/random"
      version = "3.6.1"
    }
  }
}

resource "random_id" "rng" {
  #keepers = {
    #first = "${timestamp()}"
#  }     
  byte_length = 4
}

provider "google" {
    credentials = "armageddeon-0d508d6cdae2.json"
    project = "armageddeon"
    region = "us-west1"
}


# https://medium.com/google-cloud/gcp-vpc-peering-with-terraform-fa8c69db91bd
# https://l.facebook.com/l.php?u=https%3A%2F%2Fdocs.google.com%2Fdocument%2Fd%2F1QLGAM5bGc41BRQb4eQHLGKP5rH0KnF6SpQtbzDnulsM%2Fedit%3Fusp%3Dsharing%26fbclid%3DIwZXh0bgNhZW0CMTAAAR0wq3Xv4VQf01NH23WHZi_0-J24Awe9xh4UAI-e11P_W_rWd8QbzLKMACs_aem_AUIQP6J3L-fWlcqflBdRiBHrl4F0LtTuuQ2Km8h44NGJqKEWcdXT05ZHSKegqhGtz4QF9nnzsHMSoF4-A0CQZY5N&h=AT2bKhICz_SMhaMOYwxOGT23MmuEXezZMWn-mKj-FSW5UDbh5M4OpbMT8y3X790LpvBhTWHE5V-okE5I4EBOfOe5_oVZKuBPoDZ_Zx6ogIdPPTYhK4ZbRPNOU6jp0jS_wPVQGr8IRipLwlohoGTG&__tn__=-UK-R&c[0]=AT1hlki8ObPKDGagfLsdUTo3Vb1HStV1jokCcH9jEiYFVjoiGhUFFgo8sOjiJNGV2WZQnNUcP62FJDRjQ4HEAJeRA2FX3PsV2302b4fJwSeIFAglaqKhpKDpp9LTxybIi6vJpTeATAvai2c5rBH8hVIjL2M1cM1IoirxsSbwFxNO4y30cfhqNSz0mbSZ_EOeFp_7C0z7WnBoxZKfPwvUGkUDFB-Yd5Wt58x7ROFhcm-3AXIK
# https://l.facebook.com/l.php?u=https%3A%2F%2Fdrive.google.com%2Ffile%2Fd%2F1BOSAUturBTguII9DAhN1lUkSvI1hSPK0%2Fview%3Fusp%3Dsharing%26fbclid%3DIwZXh0bgNhZW0CMTEAAR23-e160-7V_KIKagEj6IrOaVAF-i_OIqqyjBdqTwOZoaiQmWm7-mppW14_aem_AULiRhycSyfh3WRqXSPT3FfP1DlJrxHR9xBdSVlzn-TZQ5WBwlbf1xtowlIV2f0wz2ToDYMWt5dGNGKaJ31YtEgb&h=AT3TtcxK3bWMy7OnglWjxfimM1_GG7D0mbBvw6hEa7XKFkcJpz-awHjuk8s4CgBTWprLGQNyDtU92YNnkU-xSCaa59_iGmeRKjyl54spd6wBDQWetqAj01XjbpqeUMICJ9TPZuizUH17oyMsYQH2&__tn__=H-R&c[0]=AT2QHBH_U_8HAfvj7soJoJ1bxIkdUqjw5YODhOtaOJ8SUst9PmwUAiDj1YddhfODzOSncrfd73d1NRAlfKoh_U688FqG4viz7Ricipf5sbJZy7FMjkzQVoZyMRJbevykZatqG-ccRON0PzUH8nrrZqtt1duQDbIY-yo5_9latptFCSBPGCpWWTL8s96bzP1tGksBdh2CYB_MXLB8jjIyddJgiiiIZP09wZYobyvoqIKYlRs9