package com.kio.yimidelivery.api;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.http.Field;
import retrofit2.http.POST;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.PUT;

public interface APIInterface{
    @POST("registerRepartidorOnline")
    @FormUrlEncoded
    Call<ResponseBody> sendCoords(
            @Field("idRepartidor") int idRepartidor,
            @Field("disponible") byte disponible,
            @Field("nombre") String nombre,
            @Field("tel") String tel,
            @Field("tiempoUltimoServicio") int tiempoUltimoServicio,
            @Field("tiempoEstimadoUltimoServicio") int tiempoEstimadoUltimoServicio
    );

    @POST("PoolCoordenadas")
    @FormUrlEncoded
    Call<ResponseBody> updateCooordenadasRepartidor(
            @Field("coordenadasRepartidor") String nombre,
            @Field("idRepartidor") String idRepartidor
    );
}
