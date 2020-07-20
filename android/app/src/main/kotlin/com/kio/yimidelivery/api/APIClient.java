package com.kio.yimidelivery.api;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import retrofit2.Call;
import okhttp3.ResponseBody;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class APIClient {
    private final String URL = "http://yimi2.ddns.net:3000/monitoreo/";
    Retrofit retrofit;

    public APIClient() {
        Gson gson = new GsonBuilder()
                .setLenient()
                .create();
        retrofit = new Retrofit.Builder()
                .baseUrl(this.URL)
                .addConverterFactory(GsonConverterFactory.create(gson))
                .build();
    }

    public Call<ResponseBody> updateCooordenadasRepartidor(String coordenadas, String idRepartidror) {
        APIInterface api = retrofit.create(APIInterface.class);
        return api.updateCooordenadasRepartidor(coordenadas, idRepartidror);
    }
}
