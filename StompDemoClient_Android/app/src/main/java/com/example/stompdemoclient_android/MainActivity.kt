package com.example.stompdemoclient_android

import android.annotation.SuppressLint
import android.os.Bundle
import android.util.Log
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.EditText
import android.widget.ListView
import androidx.appcompat.app.AppCompatActivity
import com.google.gson.Gson
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.functions.Consumer
import io.reactivex.schedulers.Schedulers
import okhttp3.OkHttpClient
import ua.naiksoftware.stomp.Stomp
import ua.naiksoftware.stomp.dto.LifecycleEvent
import ua.naiksoftware.stomp.dto.StompMessage


class MainActivity : AppCompatActivity() {

    data class sendJsonMessage(
            val name: String,
            val message: String
    )

    val url = "ws://localhost:80/testserver"
    val intervalMillis = 1000L
    val client = OkHttpClient()

    private lateinit var mBtnConnect: Button
    private lateinit var mBtnDisonnect: Button
    private lateinit var mBtnSend: Button

    private lateinit var mEtSocketAddress: EditText
    private lateinit var mEtTopic: EditText
    private lateinit var mEtMessage: EditText

    private lateinit var mLvLog: ListView
    private lateinit var mResults: ArrayList<String>
    private lateinit var mAdapter: ArrayAdapter<String>

    @SuppressLint("CheckResult")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        mBtnConnect = findViewById<Button>(R.id.button_connect)
        mBtnDisonnect = findViewById<Button>(R.id.button_disconnect)
        mBtnSend = findViewById<Button>(R.id.button_send)

        mEtSocketAddress = findViewById<EditText>(R.id.edittext_websocketaddress)
        mEtTopic = findViewById<EditText>(R.id.edittext_topic)
        mEtMessage = findViewById<EditText>(R.id.edittext_message)

        mResults = ArrayList()
        mAdapter = ArrayAdapter(this, android.R.layout.simple_list_item_1, mResults)
        mLvLog = findViewById(R.id.logListView)
        mLvLog.transcriptMode = ListView.TRANSCRIPT_MODE_ALWAYS_SCROLL
        mLvLog.adapter = mAdapter

        val address = "ws://10.0.2.2:80/testserver/websocket"
        mEtSocketAddress.setText(address)
        val topic = "/topic/chat"
        mEtTopic.setText(topic)
        val mStompClient = Stomp.over(Stomp.ConnectionProvider.OKHTTP, address)
        mStompClient.withClientHeartbeat(1000)
        mStompClient.withServerHeartbeat(1000)

        mBtnConnect.setOnClickListener {
            mStompClient.connect()
        }

        mBtnDisonnect.setOnClickListener {

            mStompClient.disconnect()
        }

        mBtnSend.setOnClickListener {
            var gson = Gson()
            var jsonString = gson.toJson(sendJsonMessage("name","message"))
//            mStompClient.send("/app/chat", jsonString).subscribe()

            mStompClient.send(
                    "/app/chat",
                    jsonString
            ).subscribe(
                    {
                        Log.d("TAG", "STOMP echo send successfully")
                    }
            ) { throwable: Throwable ->
                Log.e("TAG", "Error send STOMP echo", throwable)
            }
        }

        // 구독 설정
        mStompClient.lifecycle()
                .subscribeOn(AndroidSchedulers.mainThread())
                .observeOn(Schedulers.io())
                .subscribe(Consumer { lifecycleEvent: LifecycleEvent ->
                    when (lifecycleEvent.type) {
                        LifecycleEvent.Type.OPENED -> {
                            Log.e("TAG", "Open")
                            runOnUiThread {
                                mResults.add("Websocket onConnected")
                                mAdapter.notifyDataSetChanged()
                            }
                        }
                        LifecycleEvent.Type.ERROR -> {
                            Log.e("TAG", "Stomp connection error", lifecycleEvent.exception)
                            runOnUiThread {
                                mResults.add("Websocket Connect Fail")
                                mAdapter.notifyDataSetChanged()
                            }
                        }
                        LifecycleEvent.Type.CLOSED -> {
                            Log.e("TAG", "Close")
                            runOnUiThread {
                                mResults.add("Websocket onDisconnect")
                                mAdapter.notifyDataSetChanged()
                            }
                        }
                        LifecycleEvent.Type.FAILED_SERVER_HEARTBEAT -> {
                            Log.e("TAG", "HeatBeat")
                            runOnUiThread {
                                mResults.add("Fail Server Heartbeat")
                                mAdapter.notifyDataSetChanged()
                            }
                        }
                    }
                })

        // 구독할 Topic 설정
        mStompClient.topic(mEtTopic.text.toString())
                .subscribeOn(Schedulers.io())
                .observeOn(Schedulers.io())
                .subscribe({
                    topicMessage: StompMessage ->
                    Log.d("TAG", "Received " + topicMessage.payload)
                    runOnUiThread {
                        mResults.add(topicMessage.payload)
                        mAdapter.notifyDataSetChanged()
                    }
                }, {
                    throwable: Throwable? -> Log.e("TAG", "Error on subscribe topic", throwable)
                })
    }
}