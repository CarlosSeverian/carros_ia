#import os
#os.system('pip3 install flask_cors')
from flask import jsonify
from flask_cors import  cross_origin  # , CORS

from flask import Flask, request
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split   # utilizado para separar dados de treino e teste
from sklearn.linear_model import LinearRegression      # Regressão linear
from sklearn.preprocessing import MinMaxScaler         # Normalizador
import joblib                                          # Gravar e Recuperar modelos
import sqlite3

app = Flask(__name__, template_folder='html')

@app.route('/lermarcas', methods=['GET', 'POST'])
@cross_origin(['localhost'])
def ler_marcasv1():
    # Lendo os dados inseridos
    ret = []
    verro = False
    try:
        sqliteConnection = sqlite3.connect('Dados/consumo_carros.db', timeout=20)
        cursor = sqliteConnection.cursor()
        sqlite_select_query = """SELECT * from tab_marcas"""
        cursor.execute(sqlite_select_query)

        for linha in cursor.fetchall():
            dicio = {"ID_Marca" : str(linha[0]), "Marca" : str(linha[1]) }
            ret.append(dicio)

        cursor.close()
    except sqlite3.Error:
        verro = True
    finally:
        if sqliteConnection:
            sqliteConnection.close()

    return jsonify({'error':verro, 'errmsg':'', 'data':ret})


@app.route('/treinar', methods=['GET', 'POST'])
@cross_origin(['localhost'])
def treinar():
    # receber os dados do json para garantir a chamada
    dados = request.get_json()
    v_Origem = dados['Origem']
    ret = []  # Treinar 4 modelos e retornar 4 scores - Etanol (cidade e estrada) e GasolinaDiesel (cidade e estrada)
    if v_Origem == "mauapos2022":
        # Lendo os dados da tabela de features
        try:
            sqliteConnection = sqlite3.connect('Dados/consumo_carros.db', timeout=20)
            cursor = sqliteConnection.cursor()
            sqlite_select_query = """SELECT * from tab_features"""
            cursor.execute(sqlite_select_query)
            cols = [column[0] for column in cursor.description]
            df_ft = pd.DataFrame.from_records(data = cursor.fetchall(), columns=cols, index = "ID_Feature")
            cursor.close()
            # inicio do treinamento
            # ONE HOT ENCODING
            # Para os campos Turbo, Ar_Condicionado, Propulsao
            #Turbo
            df_onehot = pd.get_dummies(df_ft['Turbo'])  # Criar Dataframe com os dados em OneHotEncoding
            df_onehot.columns = 'Turbo__' + df_onehot.columns  # Alterando o nome das colunas
            df_ft = pd.concat([df_ft, df_onehot], axis=1)

            #Ar_Condicionado
            df_onehot = pd.get_dummies(df_ft['Ar_Condicionado'])  # Criar Dataframe com os dados em OneHotEncoding
            df_onehot.columns = 'Ar_Condicionado__' + df_onehot.columns  # Alterando o nome das colunas
            df_ft = pd.concat([df_ft, df_onehot], axis=1)

            #Propulsao
            df_onehot = pd.get_dummies(df_ft['Propulsao'])  # Criar Dataframe com os dados em OneHotEncoding
            df_onehot.columns = 'Propulsao__' + df_onehot.columns  # Alterando o nome das colunas
            df_ft = pd.concat([df_ft, df_onehot], axis=1)

            # Normalizar Cilindradas e Valvulas
            Campos_NL = ['Cilindradas', 'Valvulas']
            scaler = MinMaxScaler(feature_range=(0, 1))
            df_ft[Campos_NL] = scaler.fit_transform(df_ft[Campos_NL])

            # Criar dataframe para Gasolina e Diesel, e manter dados X e y (cidade e estrada)
            df_ft_G = df_ft[['Cilindradas', 'Valvulas', 'Turbo__N', 'Turbo__S', 'Ar_Condicionado__N',
                            'Ar_Condicionado__S', 'Propulsao__Combustao', 'Propulsao__Hibrido', 'Propulsao__Plug-in',
                            'GasolinaDiesel_Cidade', 'GasolinaDiesel_Estrada']]

            # Criar dataframe para Etanol, e manter dados X e y (cidade e estrada)
            df_ft_E = df_ft[['combustivel','Cilindradas', 'Valvulas', 'Turbo__N', 'Turbo__S', 'Ar_Condicionado__N',
                             'Ar_Condicionado__S', 'Propulsao__Combustao', 'Propulsao__Hibrido', 'Propulsao__Plug-in',
                             'Etanol_Cidade', 'Etanol_Estrada']]
            indexNames = df_ft_E[df_ft_E['combustivel'] != 'F' ].index  # Mantendo apenas os carros Flex
            df_ft_E = df_ft_E.drop(indexNames)
            df_ft_E = df_ft_E.drop(['combustivel'], axis=1)

            TamanhoTeste = 0.2  # Aqui escolhi 80% treino e 20% teste
            # Criar 2 modelos
            # Gasolina/Diesel (cidade e estrada)
            G_X = df_ft_G[['Cilindradas', 'Valvulas', 'Turbo__N', 'Turbo__S', 'Ar_Condicionado__N',
                             'Ar_Condicionado__S', 'Propulsao__Combustao', 'Propulsao__Hibrido', 'Propulsao__Plug-in']]

            Gc_y = df_ft_G['GasolinaDiesel_Cidade']
            Ge_y = df_ft_G['GasolinaDiesel_Estrada']

            Gc_X_train, Gc_X_test, Gc_y_train, Gc_y_test = train_test_split(G_X, Gc_y, test_size=TamanhoTeste)
            Ge_X_train, Ge_X_test, Ge_y_train, Ge_y_test = train_test_split(G_X, Ge_y, test_size=TamanhoTeste)

            Modelo_Gc = LinearRegression()  # Cria instância de objeto
            Modelo_Ge = LinearRegression()  # Cria instância de objeto

            Modelo_Gc.fit(Gc_X_train, Gc_y_train)  # Treina o modelo
            y_pred = Modelo_Gc.predict(Gc_X_test)
            mape = np.round(np.mean(np.abs((Gc_y_test - y_pred) / Gc_y_test)) * 100, decimals=2)    # Mean Absolute Percentage Error
            ret.append('\nMAPE Gasolina/Diesel - Cidade: ' + str(mape) + "%")

            Modelo_Ge.fit(Ge_X_train, Ge_y_train)  # Treina o modelo
            y_pred = Modelo_Ge.predict(Ge_X_test)
            mape = np.round(np.mean(np.abs((Ge_y_test - y_pred) / Ge_y_test)) * 100, decimals=2)    # Mean Absolute Percentage Error
            ret.append('\nMAPE Gasolina/Diesel - Estrada: ' + str(mape) + "%")

            # Criar 2 modelos
            # Etanol (cidade e estrada)
            E_X = df_ft_E[['Cilindradas', 'Valvulas', 'Turbo__N', 'Turbo__S', 'Ar_Condicionado__N',
                             'Ar_Condicionado__S', 'Propulsao__Combustao', 'Propulsao__Hibrido', 'Propulsao__Plug-in']]

            Ec_y = df_ft_E['Etanol_Cidade']
            Ee_y = df_ft_E['Etanol_Estrada']

            Ec_X_train, Ec_X_test, Ec_y_train, Ec_y_test = train_test_split(E_X, Ec_y, test_size=TamanhoTeste)
            Ee_X_train, Ee_X_test, Ee_y_train, Ee_y_test = train_test_split(E_X, Ee_y, test_size=TamanhoTeste)

            Modelo_Ec = LinearRegression()  # Cria instância de objeto
            Modelo_Ee = LinearRegression()  # Cria instância de objeto

            Modelo_Ec.fit(Ec_X_train, Ec_y_train)  # Treina o modelo
            y_pred = Modelo_Ec.predict(Ec_X_test)
            mape = np.round(np.mean(np.abs((Ec_y_test - y_pred) / Ec_y_test)) * 100, decimals=2)    # Mean Absolute Percentage Error
            ret.append('\nMAPE Etanol - Cidade: ' + str(mape) + "%")

            Modelo_Ee.fit(Ee_X_train, Ee_y_train)  # Treina o modelo
            y_pred = Modelo_Ee.predict(Ee_X_test)
            mape = np.round(np.mean(np.abs((Ee_y_test - y_pred) / Ee_y_test)) * 100, decimals=2)    # Mean Absolute Percentage Error
            ret.append('\nMAPE Etanol - Estrada: ' + str(mape) + "%")

            # Os Modelos e o scaler precisam ser salvos em disco
            joblib.dump(scaler,    'Dados/scaler.pkl')
            joblib.dump(Modelo_Gc, 'Dados/Modelo_Gc.pkl')
            joblib.dump(Modelo_Ge, 'Dados/Modelo_Ge.pkl')
            joblib.dump(Modelo_Ec, 'Dados/Modelo_Ec.pkl')
            joblib.dump(Modelo_Ee, 'Dados/Modelo_Ee.pkl')

        except:
            ret = "Falha"
        finally:
            if sqliteConnection:
                sqliteConnection.close()
    else:
        ret = "Falha"
    return jsonify({'Treinamento': ret})


@app.route('/gravar', methods=['GET', 'POST'])
@cross_origin(['localhost'])
def gravar():
    ret = "Ok"
    try:
        retQ = "Falha (Tipo dos dados ou Conexão ao DB)"
        sqliteConnection = sqlite3.connect('Dados/consumo_carros.db')
        # Lendo os dados da tabela de features
        dados = request.get_json()
        v_Marca = dados['Marca']
        v_Cilindradas = float(dados['Cilindradas'])
        v_Valvulas = int(dados['Valvulas'])
        v_Turbo = dados['Turbo']
        v_Ar_Condicionado = dados['ArCondicionado']
        v_Propulsao = dados['Propulsao']
        v_Combustivel = dados['Combustivel']
        v_Consumo_Gc = float(dados['Gc'])
        v_Consumo_Ge = float(dados['Ge'])
        v_Consumo_Ec = float(dados['Ec'])
        v_Consumo_Ee = float(dados['Ee'])

        # Validar minimamente qualidade dos campos numéricos digitados
        retQ = 'Ok'
        if v_Marca == None or v_Turbo == None or v_Ar_Condicionado == None or v_Propulsao == None or v_Combustivel == None :
            retQ = "Selecione TODAS as opções"
        else:
            v_Turbo = v_Turbo[:1]
            v_Ar_Condicionado = v_Ar_Condicionado[:1]
            v_Combustivel = v_Combustivel[:1]

        if v_Cilindradas < 0.8 or v_Cilindradas > 7.0:
            retQ = "Cilindradas Inválidas (0.8 a 7.0)"

        if v_Valvulas < 0 or v_Valvulas > 50:
            retQ = "Valvulas Inválidas (Máximo 50)"

        if v_Consumo_Gc < 4 or v_Consumo_Gc > 40:
            retQ = "Consumos Inválidos Gasolina/Diesel (4 a 40)"

        if v_Consumo_Ge < 4 or v_Consumo_Ge > 40:
            retQ = "Consumos Inválidos Gasolina/Diesel (4 a 40)"

        if v_Combustivel == "F" and (v_Consumo_Ec < 4 or v_Consumo_Ec > 40):
            retQ = "Consumos Inválidos para Etanol (4 a 40)"

        if v_Combustivel == "F" and (v_Consumo_Ee < 4 or v_Consumo_Ee > 40):
            retQ = "Consumos Inválidos para Etanol (4 a 40)"

        if v_Combustivel == "F" and (v_Consumo_Ec < 4 or v_Consumo_Ec > 40):
            retQ = "Consumos Inválidos para Etanol (4 a 40)"

        if v_Combustivel == "F" and (v_Consumo_Ee < 4 or v_Consumo_Ee > 40):
            retQ = "Consumos Inválidos para Etanol (4 a 40)"

        if v_Combustivel != "F" and (v_Consumo_Ec != 0):
            retQ = "Consumos Inválidos para Etanol (digite 0)"

        if v_Combustivel != "F" and (v_Consumo_Ee != 0):
            retQ = "Consumos Inválidos para Etanol (digite 0)"

        if retQ == "Ok":
            sqliteConnection = sqlite3.connect('Dados/consumo_carros.db')
            cursor = sqliteConnection.cursor()

            campos_tabela = "(Marca, Cilindradas, Valvulas, Turbo, Ar_Condicionado, Propulsao, Combustivel, Etanol_Cidade, Etanol_Estrada, GasolinaDiesel_Cidade, GasolinaDiesel_Estrada )"
            campos_df = "("
            entrada = [v_Marca, v_Cilindradas, v_Valvulas, v_Turbo, v_Ar_Condicionado, v_Propulsao, v_Combustivel, v_Consumo_Ec, v_Consumo_Ee, v_Consumo_Gc, v_Consumo_Ge]
            for i in entrada:
                campos_df = campos_df + "'"+str(i) + "', "

            campos_df = campos_df[ : -2] + ")"

            sqlite_insert_query = " INSERT INTO tab_features " + campos_tabela + " VALUES " + campos_df
            cursor.execute(sqlite_insert_query)
            sqliteConnection.commit()
            cursor.close()
            ret = "Sucesso"
        else:
            ret = retQ

    except:
        ret = retQ
    finally:
        if sqliteConnection:
            sqliteConnection.close()

    return jsonify({'Gravacao': ret })


@app.route('/predict', methods=['GET', 'POST'])
@cross_origin(['localhost'])
def predict():
    ret = []
    try:
        # Inicialmente é preciso recuperar os modelos e o scaler em disco
        scaler =    joblib.load('Dados/scaler.pkl')
        Modelo_Gc = joblib.load('Dados/Modelo_Gc.pkl')
        Modelo_Ge = joblib.load('Dados/Modelo_Ge.pkl')
        Modelo_Ec = joblib.load('Dados/Modelo_Ec.pkl')
        Modelo_Ee = joblib.load('Dados/Modelo_Ee.pkl')


        # receber os dados do json
        dados = request.get_json()
        v_Cilindradas = float(dados['Cilindradas'])
        v_Valvulas = int(dados['Valvulas'])
        v_Turbo = dados['Turbo']
        v_Ar_Condicionado = dados['ArCondicionado']
        v_Propulsao = dados['Propulsao']
        v_Combustivel = dados['Combustivel']

        # MinMaxScaler nesses dois campos
        v_CV = np.array([v_Cilindradas, v_Valvulas]).reshape(1,-1)
        v_CV = scaler.transform(v_CV)
        v_Cilindradas = v_CV[0][0]
        v_Valvulas = v_CV[0][1]
        ###########
        if v_Turbo == "Sim":
            v_Turbo__N = 0
            v_Turbo__S = 1
        else:
            v_Turbo__N = 1
            v_Turbo__S = 0

        if v_Ar_Condicionado == "Sim":
            v_Ar_Condicionado__N = 0
            v_Ar_Condicionado__S = 1
        else:
            v_Ar_Condicionado__N = 0
            v_Ar_Condicionado__S = 1

        if v_Propulsao == "Plug-in" :
            v_Propulsao__Combustao=0
            v_Propulsao__Hibrido=  0
            v_Propulsao__Plug_in = 1
        elif v_Propulsao == "Hibrido" :
            v_Propulsao__Combustao=0
            v_Propulsao__Hibrido=  1
            v_Propulsao__Plug_in = 0
        else:
            v_Propulsao__Combustao=1
            v_Propulsao__Hibrido=  0
            v_Propulsao__Plug_in = 0

        df_predict = pd.DataFrame({'Cilindradas': [v_Cilindradas], 'Valvulas': [v_Valvulas],
                                   'Turbo__N': [v_Turbo__N], 'Turbo__S': [v_Turbo__S],
                                   'Ar_Condicionado__N' : [v_Ar_Condicionado__N],
                                   'Ar_Condicionado__S' : [v_Ar_Condicionado__S],
                                   'Propulsao__Combustao' : [v_Propulsao__Combustao],
                                   'Propulsao__Hibrido' : [v_Propulsao__Hibrido],
                                   'Propulsao__Plug-in' : [v_Propulsao__Plug_in] })

        Pred_Gc_y = str(np.round(Modelo_Gc.predict(df_predict)[0], decimals=2))
        Pred_Ge_y = str(np.round(Modelo_Ge.predict(df_predict)[0], decimals=2))

        if v_Combustivel == "Flex":
            Pred_Ec_y = str(np.round(Modelo_Ec.predict(df_predict)[0], decimals=2))
            Pred_Ee_y = str(np.round(Modelo_Ee.predict(df_predict)[0], decimals=2))
            ret.append('\nEtanol - Cidade: '+ Pred_Ec_y + 'Km/L')
            ret.append('\nEtanol - Estrada: '+ Pred_Ee_y + 'Km/L')
            ret.append('\nGasolina - Cidade: '+ Pred_Gc_y + 'Km/L')
            ret.append('\nGasolina - Estrada: '+ Pred_Ge_y + 'Km/L')
        elif v_Combustivel == "Diesel":
            ret.append('\nDiesel - Cidade: '+ Pred_Gc_y + 'Km/L')
            ret.append('\nDiesel - Estrada: '+ Pred_Ge_y + 'Km/L')
        else:
            ret.append('\nGasolina - Cidade: '+ Pred_Gc_y + 'Km/L')
            ret.append('\nGasolina - Estrada: '+ Pred_Ge_y + 'Km/L')
    except:
        ret = 'Erro'

    return jsonify({'Predição': ret})



if __name__ == "__main__":
    # quando fizer deploy mude esses valores para False
    app.run(debug=False, use_reloader=False)


