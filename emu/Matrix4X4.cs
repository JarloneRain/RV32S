using System.Security.Cryptography;

namespace RV32Semu;

struct Matrix4x4
{
    float m00, m01, m02, m03;
    float m10, m11, m12, m13;
    float m20, m21, m22, m23;
    float m30, m31, m32, m33;

    public Matrix4x4 SwapCol(int i, int j)
    {
        Matrix4x4 that = new();
        for (int row = 0; row < 4; row++)
        {
            for (int col = 0; col < 4; col++)
            {
                that[row, col] = this[row, col];
            }
            that[row, i] = this[row, j];
            that[row, j] = this[row, i];
        }
        return that;
    }
    public Matrix4x4 SwapRow(int i, int j)
    {
        Matrix4x4 that = new();
        for (int col = 0; col < 4; col++)
        {
            for (int row = 0; row < 4; row++)
            {
                that[row, col] = this[row, col];
            }
            that[i, col] = this[j, col];
            that[j, col] = this[i, col];
        }
        return that;
    }
    public Matrix4x4 MultiplyCol(float x, int i)
    {
        Matrix4x4 that = new();
        for (int row = 0; row < 4; row++)
        {
            for (int col = 0; col < 4; col++)
            {
                that[row, col] = col == i ? (x * this[row, col]) : this[row, col];
            }
        }
        return that;
    }
    public Matrix4x4 MultiplyRow(float x, int i)
    {
        Matrix4x4 that = new();
        for (int col = 0; col < 4; col++)
        {
            for (int row = 0; row < 4; row++)
            {
                that[row, col] = row == i ? (x * this[row, col]) : this[row, col];
            }
        }
        return that;
    }

    public Matrix4x4 AdditionCol(float x, int i, int j)
    {
        Matrix4x4 that = new();
        for (int row = 0; row < 4; row++)
        {
            for (int col = 0; col < 4; col++)
            {
                that[row, col] = col == j ? (x * this[row, i] + this[row, j]) : this[row, col];
            }
        }
        return that;
    }
    public Matrix4x4 AdditionRow(float x, int i, int j)
    {
        Matrix4x4 that = new();
        for (int col = 0; col < 4; col++)
        {
            for (int row = 0; row < 4; row++)
            {
                that[row, col] = row == j ? (x * this[i, col] + this[row, col]) : this[row, col];
            }
        }
        return that;
    }
    public Matrix4x4 Transpose()
    {
        Matrix4x4 that = new();
        for (int row = 0; row < 4; row++)
        {
            for (int col = 0; col < 4; col++)
            {
                that[row, col] = this[col, row];
            }
        }
        return that;
    }

    public static Matrix4x4 operator +(Matrix4x4 a, Matrix4x4 b)
    {
        Matrix4x4 c = new();
        for (int row = 0; row < 4; row++)
        {
            for (int col = 0; col < 4; col++)
            {
                c[row, col] = a[row, col] + b[row, col];
            }
        }
        return c;
    }
    public static Matrix4x4 operator -(Matrix4x4 a, Matrix4x4 b)
    {
        Matrix4x4 c = new();
        for (int row = 0; row < 4; row++)
        {
            for (int col = 0; col < 4; col++)
            {
                c[row, col] = a[row, col] - b[row, col];
            }
        }
        return c;
    }
    public static Matrix4x4 operator *(Matrix4x4 a, Matrix4x4 b)
    {
        Matrix4x4 c = new();
        for (int row = 0; row < 4; row++)
        {
            for (int col = 0; col < 4; col++)
            {
                c[row, col] = a[row, col] * b[row, col];
            }
        }
        return c;
    }
    public static Matrix4x4 operator /(Matrix4x4 a, Matrix4x4 b)
    {
        Matrix4x4 c = new();
        for (int row = 0; row < 4; row++)
        {
            for (int col = 0; col < 4; col++)
            {
                c[row, col] = a[row, col] / b[row, col];
            }
        }
        return c;
    }

    public Matrix4x4 Times(Matrix4x4 that)
    {
        Matrix4x4 result = new();
        for (int i = 0; i < 4; i++)
        {
            for (int j = 0; j < 4; j++)
            {
                for (int k = 0; k < 4; k++)
                {
                    result[i, j] += this[i, k] * that[k, j];
                }
            }
        }
        return result;
    }

    public readonly float Trace => m00 + m11 + m22 + m33;
    public readonly float Determinant => m00 * m11 * m22 * m33
                                        - m00 * m11 * m23 * m32
                                        - m00 * m12 * m21 * m33
                                        + m00 * m12 * m23 * m31
                                        + m00 * m13 * m21 * m32
                                        - m00 * m13 * m22 * m31
                                        - m01 * m10 * m22 * m33
                                        + m01 * m10 * m23 * m32
                                        + m01 * m12 * m20 * m33
                                        - m01 * m12 * m23 * m30
                                        - m01 * m13 * m20 * m32
                                        + m01 * m13 * m22 * m30
                                        + m02 * m10 * m21 * m33
                                        - m02 * m10 * m23 * m31
                                        - m02 * m11 * m20 * m33
                                        + m02 * m11 * m23 * m30
                                        + m02 * m13 * m20 * m31
                                        - m02 * m13 * m21 * m30
                                        - m03 * m10 * m21 * m32
                                        + m03 * m10 * m22 * m31
                                        + m03 * m11 * m20 * m32
                                        - m03 * m11 * m22 * m30
                                        - m03 * m12 * m20 * m31
                                        + m03 * m12 * m21 * m30;
    public float this[uint i, uint j]
    {
        get => this[(int)i, (int)j];
        set => this[(int)i, (int)j] = value;
    }
    public float this[int i, int j]
    {
        get => (i, j) switch
        {
            (0, 0) => m00,
            (0, 1) => m01,
            (0, 2) => m02,
            (0, 3) => m03,
            (1, 0) => m10,
            (1, 1) => m11,
            (1, 2) => m12,
            (1, 3) => m13,
            (2, 0) => m20,
            (2, 1) => m21,
            (2, 2) => m22,
            (2, 3) => m23,
            (3, 0) => m30,
            (3, 1) => m31,
            (3, 2) => m32,
            (3, 3) => m33,
            _ => throw new IndexOutOfRangeException("Index out of range.")
        };
        set
        {
            switch (i, j)
            {
                case (0, 0):
                    m00 = value;
                    break;
                case (0, 1):
                    m01 = value;
                    break;
                case (0, 2):
                    m02 = value;
                    break;
                case (0, 3):
                    m03 = value;
                    break;
                case (1, 0):
                    m10 = value;
                    break;
                case (1, 1):
                    m11 = value;
                    break;
                case (1, 2):
                    m12 = value;
                    break;
                case (1, 3):
                    m13 = value;
                    break;
                case (2, 0):
                    m20 = value;
                    break;
                case (2, 1):
                    m21 = value;
                    break;
                case (2, 2):
                    m22 = value;
                    break;
                case (2, 3):
                    m23 = value;
                    break;
                case (3, 0):
                    m30 = value;
                    break;
                case (3, 1):
                    m31 = value;
                    break;
                case (3, 2):
                    m32 = value;
                    break;
                case (3, 3):
                    m33 = value;
                    break;
                default:
                    throw new IndexOutOfRangeException("Index out of range.");
            }
        }

    }
}