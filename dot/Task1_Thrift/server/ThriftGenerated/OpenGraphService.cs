/**
 * Autogenerated by Thrift Compiler (0.9.3)
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 *  @generated
 */
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.IO;
using Thrift;
using Thrift.Collections;
using System.Runtime.Serialization;
using Thrift.Protocol;
using Thrift.Transport;

namespace OpenGraph
{
  public partial class OpenGraphService {
    public interface Iface {
      OpenGraphMeta GetMeta(string url);
      #if SILVERLIGHT
      IAsyncResult Begin_GetMeta(AsyncCallback callback, object state, string url);
      OpenGraphMeta End_GetMeta(IAsyncResult asyncResult);
      #endif
    }

    public class Client : IDisposable, Iface {
      public Client(TProtocol prot) : this(prot, prot)
      {
      }

      public Client(TProtocol iprot, TProtocol oprot)
      {
        iprot_ = iprot;
        oprot_ = oprot;
      }

      protected TProtocol iprot_;
      protected TProtocol oprot_;
      protected int seqid_;

      public TProtocol InputProtocol
      {
        get { return iprot_; }
      }
      public TProtocol OutputProtocol
      {
        get { return oprot_; }
      }


      #region " IDisposable Support "
      private bool _IsDisposed;

      // IDisposable
      public void Dispose()
      {
        Dispose(true);
      }
      

      protected virtual void Dispose(bool disposing)
      {
        if (!_IsDisposed)
        {
          if (disposing)
          {
            if (iprot_ != null)
            {
              ((IDisposable)iprot_).Dispose();
            }
            if (oprot_ != null)
            {
              ((IDisposable)oprot_).Dispose();
            }
          }
        }
        _IsDisposed = true;
      }
      #endregion


      
      #if SILVERLIGHT
      public IAsyncResult Begin_GetMeta(AsyncCallback callback, object state, string url)
      {
        return send_GetMeta(callback, state, url);
      }

      public OpenGraphMeta End_GetMeta(IAsyncResult asyncResult)
      {
        oprot_.Transport.EndFlush(asyncResult);
        return recv_GetMeta();
      }

      #endif

      public OpenGraphMeta GetMeta(string url)
      {
        #if !SILVERLIGHT
        send_GetMeta(url);
        return recv_GetMeta();

        #else
        var asyncResult = Begin_GetMeta(null, null, url);
        return End_GetMeta(asyncResult);

        #endif
      }
      #if SILVERLIGHT
      public IAsyncResult send_GetMeta(AsyncCallback callback, object state, string url)
      #else
      public void send_GetMeta(string url)
      #endif
      {
        oprot_.WriteMessageBegin(new TMessage("GetMeta", TMessageType.Call, seqid_));
        GetMeta_args args = new GetMeta_args();
        args.Url = url;
        args.Write(oprot_);
        oprot_.WriteMessageEnd();
        #if SILVERLIGHT
        return oprot_.Transport.BeginFlush(callback, state);
        #else
        oprot_.Transport.Flush();
        #endif
      }

      public OpenGraphMeta recv_GetMeta()
      {
        TMessage msg = iprot_.ReadMessageBegin();
        if (msg.Type == TMessageType.Exception) {
          TApplicationException x = TApplicationException.Read(iprot_);
          iprot_.ReadMessageEnd();
          throw x;
        }
        GetMeta_result result = new GetMeta_result();
        result.Read(iprot_);
        iprot_.ReadMessageEnd();
        if (result.__isset.success) {
          return result.Success;
        }
        if (result.__isset.netEx) {
          throw result.NetEx;
        }
        if (result.__isset.notFoundEx) {
          throw result.NotFoundEx;
        }
        if (result.__isset.unkEx) {
          throw result.UnkEx;
        }
        if (result.__isset.metaEx) {
          throw result.MetaEx;
        }
        throw new TApplicationException(TApplicationException.ExceptionType.MissingResult, "GetMeta failed: unknown result");
      }

    }
    public class Processor : TProcessor {
      public Processor(Iface iface)
      {
        iface_ = iface;
        processMap_["GetMeta"] = GetMeta_Process;
      }

      protected delegate void ProcessFunction(int seqid, TProtocol iprot, TProtocol oprot);
      private Iface iface_;
      protected Dictionary<string, ProcessFunction> processMap_ = new Dictionary<string, ProcessFunction>();

      public bool Process(TProtocol iprot, TProtocol oprot)
      {
        try
        {
          TMessage msg = iprot.ReadMessageBegin();
          ProcessFunction fn;
          processMap_.TryGetValue(msg.Name, out fn);
          if (fn == null) {
            TProtocolUtil.Skip(iprot, TType.Struct);
            iprot.ReadMessageEnd();
            TApplicationException x = new TApplicationException (TApplicationException.ExceptionType.UnknownMethod, "Invalid method name: '" + msg.Name + "'");
            oprot.WriteMessageBegin(new TMessage(msg.Name, TMessageType.Exception, msg.SeqID));
            x.Write(oprot);
            oprot.WriteMessageEnd();
            oprot.Transport.Flush();
            return true;
          }
          fn(msg.SeqID, iprot, oprot);
        }
        catch (IOException)
        {
          return false;
        }
        return true;
      }

      public void GetMeta_Process(int seqid, TProtocol iprot, TProtocol oprot)
      {
        GetMeta_args args = new GetMeta_args();
        args.Read(iprot);
        iprot.ReadMessageEnd();
        GetMeta_result result = new GetMeta_result();
        try {
          result.Success = iface_.GetMeta(args.Url);
        } catch (NetException netEx) {
          result.NetEx = netEx;
        } catch (NotFoundException notFoundEx) {
          result.NotFoundEx = notFoundEx;
        } catch (UnknownException unkEx) {
          result.UnkEx = unkEx;
        } catch (MetaAbsentException metaEx) {
          result.MetaEx = metaEx;
        }
        oprot.WriteMessageBegin(new TMessage("GetMeta", TMessageType.Reply, seqid)); 
        result.Write(oprot);
        oprot.WriteMessageEnd();
        oprot.Transport.Flush();
      }

    }


    #if !SILVERLIGHT
    [Serializable]
    #endif
    public partial class GetMeta_args : TBase
    {
      private string _url;

      public string Url
      {
        get
        {
          return _url;
        }
        set
        {
          __isset.url = true;
          this._url = value;
        }
      }


      public Isset __isset;
      #if !SILVERLIGHT
      [Serializable]
      #endif
      public struct Isset {
        public bool url;
      }

      public GetMeta_args() {
      }

      public void Read (TProtocol iprot)
      {
        iprot.IncrementRecursionDepth();
        try
        {
          TField field;
          iprot.ReadStructBegin();
          while (true)
          {
            field = iprot.ReadFieldBegin();
            if (field.Type == TType.Stop) { 
              break;
            }
            switch (field.ID)
            {
              case 1:
                if (field.Type == TType.String) {
                  Url = iprot.ReadString();
                } else { 
                  TProtocolUtil.Skip(iprot, field.Type);
                }
                break;
              default: 
                TProtocolUtil.Skip(iprot, field.Type);
                break;
            }
            iprot.ReadFieldEnd();
          }
          iprot.ReadStructEnd();
        }
        finally
        {
          iprot.DecrementRecursionDepth();
        }
      }

      public void Write(TProtocol oprot) {
        oprot.IncrementRecursionDepth();
        try
        {
          TStruct struc = new TStruct("GetMeta_args");
          oprot.WriteStructBegin(struc);
          TField field = new TField();
          if (Url != null && __isset.url) {
            field.Name = "url";
            field.Type = TType.String;
            field.ID = 1;
            oprot.WriteFieldBegin(field);
            oprot.WriteString(Url);
            oprot.WriteFieldEnd();
          }
          oprot.WriteFieldStop();
          oprot.WriteStructEnd();
        }
        finally
        {
          oprot.DecrementRecursionDepth();
        }
      }

      public override string ToString() {
        StringBuilder __sb = new StringBuilder("GetMeta_args(");
        bool __first = true;
        if (Url != null && __isset.url) {
          if(!__first) { __sb.Append(", "); }
          __first = false;
          __sb.Append("Url: ");
          __sb.Append(Url);
        }
        __sb.Append(")");
        return __sb.ToString();
      }

    }


    #if !SILVERLIGHT
    [Serializable]
    #endif
    public partial class GetMeta_result : TBase
    {
      private OpenGraphMeta _success;
      private NetException _netEx;
      private NotFoundException _notFoundEx;
      private UnknownException _unkEx;
      private MetaAbsentException _metaEx;

      public OpenGraphMeta Success
      {
        get
        {
          return _success;
        }
        set
        {
          __isset.success = true;
          this._success = value;
        }
      }

      public NetException NetEx
      {
        get
        {
          return _netEx;
        }
        set
        {
          __isset.netEx = true;
          this._netEx = value;
        }
      }

      public NotFoundException NotFoundEx
      {
        get
        {
          return _notFoundEx;
        }
        set
        {
          __isset.notFoundEx = true;
          this._notFoundEx = value;
        }
      }

      public UnknownException UnkEx
      {
        get
        {
          return _unkEx;
        }
        set
        {
          __isset.unkEx = true;
          this._unkEx = value;
        }
      }

      public MetaAbsentException MetaEx
      {
        get
        {
          return _metaEx;
        }
        set
        {
          __isset.metaEx = true;
          this._metaEx = value;
        }
      }


      public Isset __isset;
      #if !SILVERLIGHT
      [Serializable]
      #endif
      public struct Isset {
        public bool success;
        public bool netEx;
        public bool notFoundEx;
        public bool unkEx;
        public bool metaEx;
      }

      public GetMeta_result() {
      }

      public void Read (TProtocol iprot)
      {
        iprot.IncrementRecursionDepth();
        try
        {
          TField field;
          iprot.ReadStructBegin();
          while (true)
          {
            field = iprot.ReadFieldBegin();
            if (field.Type == TType.Stop) { 
              break;
            }
            switch (field.ID)
            {
              case 0:
                if (field.Type == TType.Struct) {
                  Success = new OpenGraphMeta();
                  Success.Read(iprot);
                } else { 
                  TProtocolUtil.Skip(iprot, field.Type);
                }
                break;
              case 1:
                if (field.Type == TType.Struct) {
                  NetEx = new NetException();
                  NetEx.Read(iprot);
                } else { 
                  TProtocolUtil.Skip(iprot, field.Type);
                }
                break;
              case 2:
                if (field.Type == TType.Struct) {
                  NotFoundEx = new NotFoundException();
                  NotFoundEx.Read(iprot);
                } else { 
                  TProtocolUtil.Skip(iprot, field.Type);
                }
                break;
              case 3:
                if (field.Type == TType.Struct) {
                  UnkEx = new UnknownException();
                  UnkEx.Read(iprot);
                } else { 
                  TProtocolUtil.Skip(iprot, field.Type);
                }
                break;
              case 4:
                if (field.Type == TType.Struct) {
                  MetaEx = new MetaAbsentException();
                  MetaEx.Read(iprot);
                } else { 
                  TProtocolUtil.Skip(iprot, field.Type);
                }
                break;
              default: 
                TProtocolUtil.Skip(iprot, field.Type);
                break;
            }
            iprot.ReadFieldEnd();
          }
          iprot.ReadStructEnd();
        }
        finally
        {
          iprot.DecrementRecursionDepth();
        }
      }

      public void Write(TProtocol oprot) {
        oprot.IncrementRecursionDepth();
        try
        {
          TStruct struc = new TStruct("GetMeta_result");
          oprot.WriteStructBegin(struc);
          TField field = new TField();

          if (this.__isset.success) {
            if (Success != null) {
              field.Name = "Success";
              field.Type = TType.Struct;
              field.ID = 0;
              oprot.WriteFieldBegin(field);
              Success.Write(oprot);
              oprot.WriteFieldEnd();
            }
          } else if (this.__isset.netEx) {
            if (NetEx != null) {
              field.Name = "NetEx";
              field.Type = TType.Struct;
              field.ID = 1;
              oprot.WriteFieldBegin(field);
              NetEx.Write(oprot);
              oprot.WriteFieldEnd();
            }
          } else if (this.__isset.notFoundEx) {
            if (NotFoundEx != null) {
              field.Name = "NotFoundEx";
              field.Type = TType.Struct;
              field.ID = 2;
              oprot.WriteFieldBegin(field);
              NotFoundEx.Write(oprot);
              oprot.WriteFieldEnd();
            }
          } else if (this.__isset.unkEx) {
            if (UnkEx != null) {
              field.Name = "UnkEx";
              field.Type = TType.Struct;
              field.ID = 3;
              oprot.WriteFieldBegin(field);
              UnkEx.Write(oprot);
              oprot.WriteFieldEnd();
            }
          } else if (this.__isset.metaEx) {
            if (MetaEx != null) {
              field.Name = "MetaEx";
              field.Type = TType.Struct;
              field.ID = 4;
              oprot.WriteFieldBegin(field);
              MetaEx.Write(oprot);
              oprot.WriteFieldEnd();
            }
          }
          oprot.WriteFieldStop();
          oprot.WriteStructEnd();
        }
        finally
        {
          oprot.DecrementRecursionDepth();
        }
      }

      public override string ToString() {
        StringBuilder __sb = new StringBuilder("GetMeta_result(");
        bool __first = true;
        if (Success != null && __isset.success) {
          if(!__first) { __sb.Append(", "); }
          __first = false;
          __sb.Append("Success: ");
          __sb.Append(Success== null ? "<null>" : Success.ToString());
        }
        if (NetEx != null && __isset.netEx) {
          if(!__first) { __sb.Append(", "); }
          __first = false;
          __sb.Append("NetEx: ");
          __sb.Append(NetEx== null ? "<null>" : NetEx.ToString());
        }
        if (NotFoundEx != null && __isset.notFoundEx) {
          if(!__first) { __sb.Append(", "); }
          __first = false;
          __sb.Append("NotFoundEx: ");
          __sb.Append(NotFoundEx== null ? "<null>" : NotFoundEx.ToString());
        }
        if (UnkEx != null && __isset.unkEx) {
          if(!__first) { __sb.Append(", "); }
          __first = false;
          __sb.Append("UnkEx: ");
          __sb.Append(UnkEx== null ? "<null>" : UnkEx.ToString());
        }
        if (MetaEx != null && __isset.metaEx) {
          if(!__first) { __sb.Append(", "); }
          __first = false;
          __sb.Append("MetaEx: ");
          __sb.Append(MetaEx== null ? "<null>" : MetaEx.ToString());
        }
        __sb.Append(")");
        return __sb.ToString();
      }

    }

  }
}