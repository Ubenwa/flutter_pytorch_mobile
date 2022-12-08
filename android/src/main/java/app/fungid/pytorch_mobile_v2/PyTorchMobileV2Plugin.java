package app.fungid.pytorch_mobile_v2;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import org.pytorch.DType;
import org.pytorch.IValue;
import org.pytorch.LiteModuleLoader;
import org.pytorch.Module;
import org.pytorch.Tensor;
import org.pytorch.torchvision.TensorImageUtils;

// Native Loader for torchscript support
import com.facebook.soloader.nativeloader.NativeLoader;
import com.facebook.soloader.nativeloader.SystemDelegate;

import java.util.ArrayList;

/** PyTorchMobileV2Plugin */
public class PyTorchMobileV2Plugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  ArrayList<Module> modules = new ArrayList<>();

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "pytorch_mobile_v2");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method){
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "loadModel":
        loadModel(call, result);
        break;
      case "predict":
        predict(call, result);
        break;
      case "predictImage":
        predictImage(call, result);
        break;
      default: 
        result.notImplemented();
        break;
    }
  }

  private void loadModel(MethodCall call, Result result) {
    try {
      String absPath = call.argument("absPath");
      
      modules.add(LiteModuleLoader.load(absPath));
      result.success(modules.size() - 1);
    } catch (Exception e) {
      String assetPath = call.argument("assetPath");
      Log.e("PyTorchMobile", assetPath + " is not a proper model", e);
    }
  }

  private void predictImage(MethodCall call, Result result) {
    Module imageModule = null;
    Bitmap bitmap = null;
    float [] mean = null;
    float [] std = null;
    try {
      int index = call.argument("index");
      byte[] imageData = call.argument("image");
      int width = call.argument("width");
      int height = call.argument("height");
      // Custom mean
      ArrayList<Double> _mean = call.argument("mean");
      mean = Convert.toFloatPrimitives(_mean.toArray(new Double[0]));

      // Custom std
      ArrayList<Double> _std = call.argument("std");
      std = Convert.toFloatPrimitives(_std.toArray(new Double[0]));

      imageModule = modules.get(index);

      bitmap = BitmapFactory.decodeByteArray(imageData,0,imageData.length);

      bitmap = Bitmap.createScaledBitmap(bitmap, width, height, false);

    }catch (Exception e){
      Log.e("PyTorchMobile", "error reading image", e);
    }

    final Tensor imageInputTensor = TensorImageUtils.bitmapToFloat32Tensor(bitmap,
            mean, std);

    final Tensor imageOutputTensor = imageModule.forward(IValue.from(imageInputTensor)).toTensor();

    float[] scores = imageOutputTensor.getDataAsFloatArray();

    ArrayList<Float> out = new ArrayList<>();
    for(float f : scores){
      out.add(f);
    }

    result.success(out);
  }

  private void predict(MethodCall call, Result result) {
    Module module = null;
    Integer[] shape = null;
    Double[] data = null;
    DType dtype = null;

    try{
      int index = call.argument("index");
      module = modules.get(index);

      dtype = DType.valueOf(call.argument("dtype").toString().toUpperCase());

      ArrayList<Integer> shapeList = call.argument("shape");
      shape = shapeList.toArray(new Integer[shapeList.size()]);

      ArrayList<Double> dataList = call.argument("data");
      data = dataList.toArray(new Double[dataList.size()]);

    }catch(Exception e){
      Log.e("PyTorchMobile", "error parsing arguments", e);
    }

    //prepare input tensor
    final Tensor inputTensor = getInputTensor(dtype, data, shape);

    //run model
    Tensor outputTensor = null;
    try {
      outputTensor = module.forward(IValue.from(inputTensor)).toTensor();
    }catch(RuntimeException e){
      Log.e("PyTorchMobile", "Your input type " + dtype.toString().toLowerCase()  + " (" + Convert.dtypeAsPrimitive(dtype.toString()) +") " + "does not match with model input type",e);
      result.success(null);
    }

    successResult(result, dtype, outputTensor);
  }




  //returns input tensor depending on dtype
  private Tensor getInputTensor(DType dtype, Double[] data, Integer[] shape){
    switch (dtype){
      case FLOAT32:
        return Tensor.fromBlob(Convert.toFloatPrimitives(data), Convert.toPrimitives(shape));
      case FLOAT64:
        return  Tensor.fromBlob(Convert.toDoublePrimitives(data), Convert.toPrimitives(shape));
      case INT32:
        return Tensor.fromBlob(Convert.toIntegerPrimitives(data), Convert.toPrimitives(shape));
      case INT64:
        return Tensor.fromBlob(Convert.toLongPrimitives(data), Convert.toPrimitives(shape));
      case INT8:
        return Tensor.fromBlob(Convert.toBytePrimitives(data), Convert.toPrimitives(shape));
      case UINT8:
        return Tensor.fromBlobUnsigned(Convert.toBytePrimitives(data), Convert.toPrimitives(shape));
      default:
        return null;
    }
  }

  //gets tensor depending on dtype and creates list of it, which is being returned
  private void successResult(Result result, DType dtype, Tensor outputTensor){
    switch (dtype){
      case FLOAT32:
        ArrayList<Float> outputListFloat = new ArrayList<>();
        for(float f : outputTensor.getDataAsFloatArray()){
          outputListFloat.add(f);
        }
        result.success(outputListFloat);
        break;
      case FLOAT64:
        ArrayList<Double> outputListDouble = new ArrayList<>();
        for(double d : outputTensor.getDataAsDoubleArray()){
          outputListDouble.add(d);
        }
        result.success(outputListDouble);
        break;
      case INT32:
        ArrayList<Integer> outputListInteger = new ArrayList<>();
        for(int i : outputTensor.getDataAsIntArray()){
          outputListInteger.add(i);
        }
        result.success(outputListInteger);
        break;
      case INT64:
        ArrayList<Long> outputListLong = new ArrayList<>();
        for(long l : outputTensor.getDataAsLongArray()){
          outputListLong.add(l);
        }
        result.success(outputListLong);
        break;
      case INT8:
        ArrayList<Byte> outputListByte = new ArrayList<>();
        for(byte b : outputTensor.getDataAsByteArray()){
          outputListByte.add(b);
        }
        result.success(outputListByte);
        break;
      case UINT8:
        ArrayList<Byte> outputListUByte = new ArrayList<>();
        for(byte ub : outputTensor.getDataAsUnsignedByteArray()){
          outputListUByte.add(ub);
        }
        result.success(outputListUByte);
        break;
      default:
        result.success(null);
        break;
    }
  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
